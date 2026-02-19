// API configuration constants that match FastAPI backend.

class ApiConstants {
  // Private constructor - this class should not be instantiated
  ApiConstants._();

  // ============================================================
  // Base Configuration
  // ============================================================

  // Using ADB reverse port forwarding (USB connection)
  // This forwards phone's localhost:8000 → computer's localhost:8000
  //
  // To set up (run once when phone connects):
  //   adb reverse tcp:8000 tcp:8000
  //
  // This works regardless of WiFi network!
  static const String baseUrl = 'http://localhost:8000';

  // API version prefix
  static const String apiPrefix = '/api/v1';

  // Full API base URL
  static String get apiBaseUrl => '$baseUrl$apiPrefix';

  // ============================================================
  // Auth Endpoints
  // ============================================================

  /// POST - Register new user
  /// Request: { email, password, full_name }
  /// Response: TokenResponse with access_token, refresh_token, user
  static String get register => '$apiBaseUrl/auth/register';
  
  /// POST - Login user
  /// Request: { email, password }
  /// Response: TokenResponse
  static String get login => '$apiBaseUrl/auth/login';

  /// POST - Refresh access token
  /// Request: { refresh_token }
  /// Response: { access_token, token_type, expires_in }
  static String get refreshToken => '$apiBaseUrl/auth/refresh';
  
  /// GET - Get current user info (requires Bearer token)
  /// Response: UserResponse
  static String get me => '$apiBaseUrl/auth/me';
  
  /// POST - Request password reset code
  /// Request: { email }
  /// Response: { message, success }
  static String get forgotPassword => '$apiBaseUrl/auth/forgot-password';
  
  /// POST - Verify reset code is valid
  /// Request: { email, code }
  /// Response: { message, success }
  static String get verifyResetCode => '$apiBaseUrl/auth/verify-reset-code';
  
  /// POST - Reset password with code
  /// Request: { email, code, new_password }
  /// Response: { message, success }
  static String get resetPassword => '$apiBaseUrl/auth/reset-password';

  // ============================================================
  // Project Endpoints
  // ============================================================

  /// GET - List user's projects
  /// Query: skip, limit
  /// Response: List of ProjectResponse
  /// 
  /// POST - Create new project
  /// Request: { name, description? }
  /// Response: ProjectResponse
  static String get projects => '$apiBaseUrl/projects';

  /// GET - Get project details
  /// Response: ProjectResponse
  /// 
  /// PATCH - Update project
  /// Request: { name?, description?, is_archived? }
  /// Response: ProjectResponse
  /// 
  /// DELETE - Delete project
  static String project(String projectId) => '$apiBaseUrl/projects/$projectId';

  // ============================================================
  // Document Endpoints (nested under projects)
  // ============================================================

  /// GET - List documents in project
  /// Query: status?, file_type?, limit, offset
  /// Response: DocumentListResponse
  /// 
  /// POST - Upload document (multipart/form-data)
  /// Response: DocumentUploadResponse
  static String documents(String projectId) => 
      '$apiBaseUrl/projects/$projectId/documents';

  /// GET - Get document stats
  /// Response: { total, by_status, by_type, total_size }
  static String documentStats(String projectId) => 
      '$apiBaseUrl/projects/$projectId/documents/stats';

  /// GET - Get document details
  /// Response: DocumentResponse
  /// 
  /// DELETE - Delete document
  static String document(String projectId, String documentId) => 
      '$apiBaseUrl/projects/$projectId/documents/$documentId';

  /// POST - Reprocess failed document
  /// Response: DocumentResponse
  static String reprocessDocument(String projectId, String documentId) => 
      '$apiBaseUrl/projects/$projectId/documents/$documentId/reprocess';

  /// GET - Download document file
  /// Response: File stream
  static String downloadDocument(String projectId, String documentId) => 
      '$apiBaseUrl/projects/$projectId/documents/$documentId/download';

  /// GET - Get allowed file types (no auth required)
  /// Response: { allowed_extensions, max_file_size_mb, max_file_size_bytes }
  static String allowedFileTypes(String projectId) => 
      '$apiBaseUrl/projects/$projectId/documents/info/allowed-types';

  // ============================================================
  // Conversation Endpoints
  // ============================================================

  /// GET - List conversations
  /// Query: project_id?, skip, limit
  /// Response: ConversationListResponse
  /// 
  /// POST - Create conversation
  /// Request: { project_id?, title?, is_socratic?, initial_message? }
  /// Response: ConversationWithMessages
  static String get conversations => '$apiBaseUrl/conversations';

  /// GET - Get conversation with messages
  /// Response: ConversationWithMessages
  /// 
  /// PATCH - Update conversation
  /// Request: { title?, is_socratic? }
  /// Response: ConversationResponse
  /// 
  /// DELETE - Delete conversation
  static String conversation(String conversationId) => 
      '$apiBaseUrl/conversations/$conversationId';

  /// POST - Send message (non-streaming)
  /// Request: { message }
  /// Response: ChatResponse
  static String messages(String conversationId) => 
      '$apiBaseUrl/conversations/$conversationId/messages';

  /// POST - Send message (streaming via SSE)
  /// Request: { message }
  /// Response: Server-Sent Events stream
  static String messagesStream(String conversationId) => 
      '$apiBaseUrl/conversations/$conversationId/messages/stream';

  // ============================================================
  // Sharing Endpoints
  // ============================================================

  /// POST - Create public share link
  /// Query: conversation_id
  /// Request: { title?, allow_replies?, expires_in_days? }
  /// Response: SharedConversationResponse
  /// 
  /// GET - List my shares
  /// Response: SharedByMeListResponse
  static String get shares => '$apiBaseUrl/shares';

  /// GET - Get share details
  /// PATCH - Update share settings
  /// DELETE - Delete share
  static String share(String shareId) => '$apiBaseUrl/shares/$shareId';

  /// GET - Get share statistics
  static String shareStats(String shareId) => '$apiBaseUrl/shares/$shareId/stats';

  /// GET - View shared conversation (no auth required)
  /// Response: SharedConversationFull
  static String sharedConversation(String token) => '$apiBaseUrl/shared/$token';

  /// POST - Fork shared conversation
  /// Request: { initial_message? }
  /// Response: ConversationForkResponse
  static String forkSharedConversation(String token) => '$apiBaseUrl/shared/$token/fork';

  /// POST - Share privately with users
  /// Request: { user_emails, can_reply? }
  /// Response: List<ConversationAccessResponse>
  static String sharePrivate(String conversationId) => 
      '$apiBaseUrl/conversations/$conversationId/share-private';

  /// GET - List conversations shared with me
  /// Response: SharedWithMeListResponse
  static String get sharedWithMe => '$apiBaseUrl/shared-with-me';

  /// DELETE - Revoke user access
  static String revokeAccess(String conversationId, String userId) => 
      '$apiBaseUrl/conversations/$conversationId/access/$userId';

  /// POST - Fork a conversation I have access to
  /// Request: { initial_message? }
  /// Response: ConversationForkResponse
  static String forkConversation(String conversationId) => 
      '$apiBaseUrl/conversations/$conversationId/fork';

  // ============================================================
  // WebSocket Endpoints
  // ============================================================
  
  /// WebSocket base URL (ws:// for http://, wss:// for https://)
  static String get wsBaseUrl {
    if (baseUrl.startsWith('https://')) {
      return baseUrl.replaceFirst('https://', 'wss://');
    }
    return baseUrl.replaceFirst('http://', 'ws://');
  }
  
  /// WS - Real-time message sync
  /// Connects to conversation WebSocket for live updates
  /// Query param: ?token=\<access_token\>
  static String conversationWs(String conversationId) =>
      '$wsBaseUrl$apiPrefix/conversations/$conversationId/ws';

  // ============================================================
  // Timeouts (in milliseconds)
  // ============================================================
  
  static const int connectionTimeout = 60000; // 60 seconds
  static const int receiveTimeout = 60000;    // 60 seconds
  
  // Longer timeout for file uploads
  static const int uploadTimeout = 120000;    // 2 minutes
}
