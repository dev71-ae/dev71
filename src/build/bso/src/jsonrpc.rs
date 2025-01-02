use std::io::{self, BufRead, Read};

use serde::{Deserialize, Deserializer, Serialize, Serializer, de};
use serde_json::{self as json};

#[derive(Serialize, Deserialize, Debug)]
pub enum Id {
    String(String),
    Number(i32),
    Null,
}

#[derive(Serialize, Deserialize, Debug)]
pub enum Message {
    Request(Request),
    Notification(Notification),
    Response(Response),
}

#[derive(Debug)]
pub enum ErrorCode {
    ParseError,
    InvalidRequest,
    MethodNotFound,
    InvalidParams,
    InternalError,
    ServerError(i32),
}

#[derive(Serialize, Deserialize, Debug)]
#[serde(deny_unknown_fields)]
struct JsonRpc {
    jsonrpc: String,

    #[serde(flatten)]
    pub message: Message,
}

#[derive(Serialize, Deserialize, Debug)]
#[serde(deny_unknown_fields)]
pub struct Request {
    pub id: Id,
    pub method: String,

    #[serde(skip_serializing_if = "json::Value::is_null")]
    pub params: json::Value,
}

#[derive(Serialize, Deserialize, Debug)]
#[serde(deny_unknown_fields)]
pub struct Response {
    pub id: Id,

    #[serde(skip_serializing_if = "Option::is_none")]
    pub result: Option<json::Value>,

    #[serde(skip_serializing_if = "Option::is_none")]
    pub error: Option<ResponseError>,
}

#[derive(Serialize, Deserialize, Debug)]
#[serde(deny_unknown_fields)]
pub struct ResponseError {
    pub code: ErrorCode,
    pub message: String,

    #[serde(skip_serializing_if = "Option::is_none")]
    pub data: Option<serde_json::Value>,
}

#[derive(Serialize, Deserialize, Debug)]
#[serde(deny_unknown_fields)]
pub struct Notification {
    pub method: String,

    #[serde(skip_serializing_if = "serde_json::Value::is_null")]
    pub params: json::Value,
}

fn invalid_data(reason: &str) -> io::Error {
    io::Error::new(io::ErrorKind::InvalidData, reason)
}

pub trait RequestType {
    const METHOD: &str;
    type Response;
}

impl ErrorCode {
    const PARSE_ERROR: i32 = -32700;
    const INVALID_REQUEST: i32 = -32600;
    const METHOD_NOT_FOUND: i32 = -32601;
    const INVALID_PARAMS: i32 = -32602;
    const INTERNAL_ERROR: i32 = -32603;

    pub const fn code(&self) -> i32 {
        use ErrorCode::*;
        match *self {
            ParseError => Self::PARSE_ERROR,
            MethodNotFound => Self::METHOD_NOT_FOUND,
            InvalidRequest => Self::INVALID_REQUEST,
            InvalidParams => Self::INVALID_PARAMS,
            InternalError => Self::INTERNAL_ERROR,
            ServerError(c) => c,
        }
    }
}

impl TryFrom<i32> for ErrorCode {
    type Error = String;

    fn try_from(code: i32) -> Result<Self, Self::Error> {
        use ErrorCode::*;
        match code {
            Self::PARSE_ERROR => Ok(ParseError),
            Self::METHOD_NOT_FOUND => Ok(MethodNotFound),
            Self::INVALID_REQUEST => Ok(InvalidRequest),
            Self::INVALID_PARAMS => Ok(InvalidParams),
            Self::INTERNAL_ERROR => Ok(InternalError),
            c if (-32099..=-32000).contains(&c) => Ok(ServerError(c)),
            c => Err(format!("invalid error code: {c}")),
        }
    }
}

impl<'a> serde::Deserialize<'a> for ErrorCode {
    fn deserialize<D>(deserializer: D) -> Result<ErrorCode, D::Error>
    where
        D: Deserializer<'a>,
    {
        let code: i32 = Deserialize::deserialize(deserializer)?;
        ErrorCode::try_from(code).map_err(de::Error::custom)
    }
}

impl serde::Serialize for ErrorCode {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: Serializer,
    {
        serializer.serialize_i32(self.code())
    }
}

pub fn parse_message(reader: &mut impl BufRead) -> io::Result<Message> {
    const MAX_CONTENT_LENGTH: usize = 50 * 1024 * 1024; // 50 MB

    let mut buffer = String::with_capacity(1024);
    reader.read_line(&mut buffer)?;

    let (header_name, header_value) = buffer
        .split_once(": ")
        .ok_or_else(|| invalid_data("malformed header"))?;

    if !header_name.eq_ignore_ascii_case("Content-Length") {
        return Err(invalid_data("missing content-length header"));
    }

    let content_length = header_value
        .trim_end()
        .parse::<usize>()
        .map_err(|_| invalid_data("failed to parse content-length"))?;

    if content_length == 0 || content_length > MAX_CONTENT_LENGTH {
        return Err(invalid_data("invalid content-length size"));
    }

    buffer.clear();
    reader.read_line(&mut buffer)?;

    if !matches!(buffer.as_str(), "\n" | "\r\n") {
        return Err(invalid_data("malformed message"));
    }

    buffer.clear();
    buffer.reserve(content_length);
    reader
        .take(content_length as u64)
        .read_to_string(&mut buffer)?;

    json::from_str(&buffer).map_err(|e| invalid_data(&e.to_string()))
}
