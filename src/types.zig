const std = @import("std");
const json = std.json;
const MaybeDefined = @import("json_serialize.zig").MaybeDefined;

pub const String = []const u8;
pub const Integer = i64;
pub const Float = f64;
pub const Bool = bool;
pub const Array = json.Array;
pub const Object = json.ObjectMap;
pub const Any = json.Value;

// Specification:
// https://microsoft.github.io/language-server-protocol/specifications/specification-current/

pub const RequestId = union(enum) {
    String: String,
    Integer: Integer,
    Float: Float,
};

pub const Request = struct {
    jsonrpc: String = "2.0",
    method: String,

    /// Must be an Array or an Object
    params: Any,
    id: MaybeDefined(RequestId) = .NotDefined,

    pub fn validate(self: *const Request) bool {
        if (!std.mem.eql(u8, self.jsonrpc, "2.0")) {
            return false;
        }
        return switch (self.params) {
            .Object, .Array => true,
            else => false,
        };
    }
};

pub const Response = struct {
    jsonrpc: String = "2.0",
    @"error": MaybeDefined(Error) = .NotDefined,
    result: MaybeDefined(Any) = .NotDefined,
    id: ?RequestId,

    pub const Error = struct {
        code: Integer,
        message: String,
        data: MaybeDefined(Any),
    };

    pub fn validate(self: *const Response) bool {
        if (!std.mem.eql(u8, self.jsonrpc, "2.0")) {
            return false;
        }

        const errorDefined = self.@"error" == .Defined;
        const resultDefined = self.result == .Defined;

        // exactly one of them must be defined
        return errorDefined != resultDefined;
    }
};

pub const ErrorCodes = struct {
    // Defined by JSON RPC
    pub const ParseError = -32700;
    pub const InvalidRequest = -32600;
    pub const MethodNotFound = -32601;
    pub const InvalidParams = -32602;
    pub const InternalError = -32603;

    // Implementation specific JSON RPC errors
    pub const serverErrorStart = -32099;
    pub const serverErrorEnd = -32000;
    pub const ServerNotInitialized = -32002;
    pub const UnknownErrorCode = -32001;

    // Defined by LSP
    pub const RequestCancelled = -32800;
    pub const ContentModified = -32801;
};

pub const DocumentUri = String;

pub const Position = struct {
    line: Integer,
    character: Integer,
};

pub const Range = struct {
    start: Position,
    end: Position,
};

pub const Location = struct {
    uri: DocumentUri,
    range: Range,
};

pub const LocationLink = struct {
    originSelectionRange: MaybeDefined(Range) = .NotDefined,
    targetUri: DocumentUri,
    targetRange: Range,
    targetSelectionRange: Range,
};

pub const Diagnostic = struct {
    range: Range,
    severity: MaybeDefined(DiagnosticSeverity) = .NotDefined,
    code: MaybeDefined(Any) = .NotDefined,
    source: MaybeDefined(String) = .NotDefined,
    message: String,
    relatedInformation: MaybeDefined([]DiagnosticRelatedInformation) = .NotDefined,
};

pub const DiagnosticRelatedInformation = struct {
    location: Location,
    message: String,
};

pub const DiagnosticSeverity = enum(Integer) {
    Error = 1,
    Warning = 2,
    Information = 3,
    Hint = 4,
    _,
};

pub const Command = struct {
    title: String,
    command: String,
    arguments: MaybeDefined([]Any),
};

pub const TextEdit = struct {
    range: Range,
    newText: String,
};

pub const TextDocumentSyncKind = enum(Integer) {
    None = 0,
    Full = 1,
    Incremental = 2,
    _,
};

pub const InitializeParams = struct {
    processId: ?Integer,
    rootPath: MaybeDefined(?String),
    rootUri: ?DocumentUri,
    initializationOptions: MaybeDefined(Any),
    capabilities: ClientCapabilities,
    // trace: MaybeDefined(String),
    // workspaceFolders: MaybeDefined(?[]WorkspaceFolder),
};

pub const InitializedParams = struct {};

pub const Trace = struct {
    pub const Off = "off";
    pub const Messages = "messages";
    pub const Verbose = "verbose";
};

pub const WorkspaceFolder = struct {};
pub const ClientCapabilities = struct {};

pub const DidChangeTextDocumentParams = struct {
    contentChanges: []TextDocumentContentChangeEvent,
    textDocument: VersionedTextDocumentIdentifier,
};

pub const TextDocumentContentChangeEvent = struct {
    range: MaybeDefined(Range),
    text: String,
};

pub const TextDocumentIdentifier = struct {
    uri: DocumentUri,
};

pub const VersionedTextDocumentIdentifier = struct {
    uri: DocumentUri,
    version: ?Integer,
};

pub const PublishDiagnosticsParams = struct {
    uri: DocumentUri,
    diagnostics: []Diagnostic,
};

pub const CompletionParams = struct {
    textDocument: TextDocumentIdentifier,
    position: Position,
    context: MaybeDefined(CompletionContext),
};

pub const CompletionTriggerKind = enum(Integer) {
    Invoked = 1,
    TriggerCharacter = 2,
    TriggerForIncompleteCompletions = 3,
    _,
};

pub const CompletionContext = struct {
    triggerKind: CompletionTriggerKind,
    triggerCharacter: MaybeDefined(String),
};

// not complete definition
pub const CompletionItem = struct {
    label: String,
    kind: MaybeDefined(CompletionItemKind) = .NotDefined,
    textEdit: MaybeDefined(TextEdit) = .NotDefined,
    filterText: MaybeDefined(String) = .NotDefined,
};

pub const CompletionItemKind = enum(Integer) {
    Text = 1,
    Method = 2,
    Function = 3,
    Constructor = 4,
    Field = 5,
    Variable = 6,
    Class = 7,
    Interface = 8,
    Module = 9,
    Property = 10,
    Unit = 11,
    Value = 12,
    Enum = 13,
    Keyword = 14,
    Snippet = 15,
    Color = 16,
    File = 17,
    Reference = 18,
    Folder = 19,
    EnumMember = 20,
    Constant = 21,
    Struct = 22,
    Event = 23,
    Operator = 24,
    TypeParameter = 25,
    _,
};

pub const DidCloseTextDocumentParams = struct {
    textDocument: TextDocumentIdentifier,
};

pub const DidOpenTextDocumentParams = struct {
    textDocument: TextDocumentItem,
};

pub const TextDocumentItem = struct {
    uri: DocumentUri,
    languageId: String,
    version: Integer,
    text: String,
};
