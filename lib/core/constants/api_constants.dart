// API configuration constants that match FastAPI backend.

class ApiConstants {
  // Private constructor - this class should not be instantiated
  ApiConstants._();

  // ============================================================
  // Base Configuration
  // ============================================================

  // IMPORTANT: For physical devices, your phone and computer 
  // must be on the SAME WiFi network!
  //
  // To find your computer's IP:
  //   Linux: hostname -I
  //   Mac: ifconfig | grep "inet "
  //   Windows: ipconfig
  //
  // Current setup: Physical Android device
  static const String baseUrl = 'http://192.168.137.199:8000';

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
  // Timeouts (in milliseconds)
  // ============================================================
  
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000;    // 30 seconds
  
  // Longer timeout for file uploads
  static const int uploadTimeout = 120000;    // 2 minutes
}
