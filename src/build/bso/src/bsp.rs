//! BSP Ver. 2.2.0 with extensions { sourcekit-lsp }
//! NOTE: This is not comprehensive; if it were to be, please generate it from the smithy specification in the BSP repo.

use serde::{Deserialize, Serialize};

use crate::jsonrpc;

use serde_json::Value as Any; // This is fine for now

#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase", deny_unknown_fields)]
pub struct InitializeBuild {
    /// Name of the client
    display_name: String,
    /// The version of the client
    version: String,
    /// The BSP version that the client speaks
    bsp_version: String,
    /// The rootUri of the workspace
    root_uri: String,
    /// The capabilities of the client
    capabilities: BuildClientCapabilities,
    /// Kind of data to expect in the `data` field. If this field is not set, the kind of data is not specified.
    data_kind: Option<String>,
    /// Additional metadata about the client
    data: Option<Any>,
}

impl jsonrpc::RequestType for InitializeBuild {
    const METHOD: &str = "build/initialize";
    type Response = InitializeBuildResponse;
}

#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase", deny_unknown_fields)]
pub struct InitializeBuildResponse {
    /// Name of the server
    display_name: String,
    /// The version of the server
    version: String,
    /// The BSP version that the server speaks
    bsp_version: String,
    /// The capabilities of the build server
    capabilities: BuildServerCapabilities,
    /// Kind of data to expect in the `data` field. If this field is not set, the kind of data is not specified.
    data_kind: Option<String>,
    /// Optional metadata about the server
    data: Option<Any>,
}

#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase", deny_unknown_fields)]
pub struct BuildClientCapabilities {
    /// The languages that this client supports.
    /// The ID strings for each language is defined in the LSP.
    /// The server must never respond with build targets for other
    /// languages than those that appear in this list.
    language_ids: Vec<LanguageId>,
    /// Mirror capability to BuildServerCapabilities.jvmCompileClasspathProvider
    /// The client will request classpath via `buildTarget/jvmCompileClasspath` so
    /// it's safe to return classpath in ScalacOptionsItem empty.
    jvm_compile_classpath_receiver: Option<bool>,
}

#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase", deny_unknown_fields)]
pub struct BuildServerCapabilities {
    /// The languages the server supports compilation via method buildTarget/compile.
    compile_provider: Option<CompileProvider>,
    /// The languages the server supports test execution via method buildTarget/test
    test_provider: Option<TestProvider>,
    /// The languages the server supports run via method buildTarget/run
    run_provider: Option<RunProvider>,
    /// The languages the server supports debugging via method debugSession/start.
    debug_provider: Option<DebugProvider>,
    /// The server can provide a list of targets that contain a
    /// single text document via the method buildTarget/inverseSources
    inverse_sources_provider: Option<bool>,
    /// The server provides sources for library dependencies
    /// via method buildTarget/dependencySources
    dependency_sources_provider: Option<bool>,
    /// The server provides all theboolource dependencies
    /// via method buildTarget/resources
    resources_provider: Option<bool>,
    /// The server provides all output paths
    /// via method buildTarget/outputPaths
    output_paths_provider: Option<bool>,
    /// The server sends notifications to the client on build
    /// target change events via `buildTarget/didChange`
    build_target_changed_provider: Option<bool>,
    /// The server can respond to `buildTarget/jvmRunEnvironment` requests with the
    /// necessary information required to launch a Java process to run a main class.
    jvm_run_environment_provider: Option<bool>,
    /// The server can respond to `buildTarget/jvmTestEnvironment` requests with the
    /// necessary information required to launch a Java process for testing or
    /// debugging.
    jvm_test_environment_provider: Option<bool>,
    /// The server can respond to `workspace/cargoFeaturesState` and
    /// `setCargoFeatures` requests. In other words, supports Cargo Features extension.
    cargo_features_provider: Option<bool>,
    /// Reloading the build state through workspace/reload is supported
    can_reload: Option<bool>,
    /// The server can respond to `buildTarget/jvmCompileClasspath` requests with the
    /// necessary information about the target's classpath.
    jvm_compile_classpath_provider: Option<bool>,
}

#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase", deny_unknown_fields)]
pub struct CompileProvider {
    language_ids: Vec<LanguageId>,
}

#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase", deny_unknown_fields)]
pub struct TestProvider {
    language_ids: Vec<LanguageId>,
}

#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase", deny_unknown_fields)]
pub struct RunProvider {
    language_ids: Vec<LanguageId>,
}

#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase", deny_unknown_fields)]
pub struct DebugProvider {
    language_ids: Vec<LanguageId>,
}

#[derive(Serialize, Deserialize)]
pub enum LanguageId {
    #[serde(rename = "abap")]
    Abap,

    #[serde(rename = "bat")]
    WindowsBat,

    #[serde(rename = "bibtex")]
    BibTeX,

    #[serde(rename = "clojure")]
    Clojure,

    #[serde(rename = "coffeescript")]
    Coffeescript,

    #[serde(rename = "c")]
    C,

    #[serde(rename = "cpp")]
    Cpp,

    #[serde(rename = "csharp")]
    Csharp,

    #[serde(rename = "css")]
    Css,

    #[serde(rename = "d")]
    D,

    #[serde(rename = "diff")]
    Diff,

    #[serde(rename = "dart")]
    Dart,

    #[serde(rename = "dockerfile")]
    Dockerfile,

    #[serde(rename = "elixir")]
    Elixir,

    #[serde(rename = "erlang")]
    Erlang,

    #[serde(rename = "fsharp")]
    Fsharp,

    #[serde(rename = "git-commit")]
    GitCommit,

    #[serde(rename = "rebase")]
    GitRebase,

    #[serde(rename = "go")]
    Go,

    #[serde(rename = "groovy")]
    Groovy,

    #[serde(rename = "handlebars")]
    Handlebars,

    #[serde(rename = "haskell")]
    Haskell,

    #[serde(rename = "html")]
    Html,

    #[serde(rename = "ini")]
    Ini,

    #[serde(rename = "java")]
    Java,

    #[serde(rename = "javascript")]
    JavaScript,

    #[serde(rename = "javascriptreact")]
    JavaScriptReact,

    #[serde(rename = "json")]
    Json,

    #[serde(rename = "latex")]
    LaTeX,

    #[serde(rename = "less")]
    Less,

    #[serde(rename = "lua")]
    Lua,

    #[serde(rename = "makefile")]
    Makefile,

    #[serde(rename = "markdown")]
    Markdown,

    #[serde(rename = "objective-c")]
    ObjectiveC,

    #[serde(rename = "objective-cpp")]
    ObjectiveCpp,

    #[serde(rename = "pascal")]
    Pascal,

    #[serde(rename = "perl")]
    Perl,

    #[serde(rename = "perl6")]
    Perl6,

    #[serde(rename = "php")]
    Php,

    #[serde(rename = "powershell")]
    Powershell,

    #[serde(rename = "jade")]
    Pug,

    #[serde(rename = "python")]
    Python,

    #[serde(rename = "r")]
    R,

    #[serde(rename = "razor")]
    Razor,

    #[serde(rename = "ruby")]
    Ruby,

    #[serde(rename = "rust")]
    Rust,

    #[serde(rename = "scss")]
    Scss,

    #[serde(rename = "sass")]
    Sass,

    #[serde(rename = "scala")]
    Scala,

    #[serde(rename = "shaderlab")]
    ShaderLab,

    #[serde(rename = "shellscript")]
    ShellScript,

    #[serde(rename = "sql")]
    Sql,

    #[serde(rename = "swift")]
    Swift,

    #[serde(rename = "typescript")]
    TypeScript,

    #[serde(rename = "typescriptreact")]
    TypeScriptReact,

    #[serde(rename = "tex")]
    TeX,

    #[serde(rename = "vb")]
    VisualBasic,

    #[serde(rename = "xml")]
    Xml,

    #[serde(rename = "xsl")]
    Xsl,

    #[serde(rename = "yaml")]
    Yaml,
}

struct OnBuildInitialize; // Notification

struct BuildShutdown; // Request
struct OnBuildExit; // Notification
