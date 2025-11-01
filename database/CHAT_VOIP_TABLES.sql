-- ========================================
-- TABLES POUR SYSTÈME DE CHAT ET VOIP
-- Venus Pharmaceutical Distribution
-- MySQL Database Schema
-- ========================================

USE venus_db;

-- ========================================
-- TABLE: chat_conversations
-- ========================================
CREATE TABLE IF NOT EXISTS chat_conversations (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    conversation_code VARCHAR(50) UNIQUE NOT NULL,
    conversation_type ENUM('DIRECT', 'GROUP', 'SUPPORT', 'INTERNAL', 'ORDER_RELATED', 'EMERGENCY') NOT NULL,
    title VARCHAR(255),
    customer_id BIGINT,
    created_by BIGINT NOT NULL,
    assigned_to BIGINT,
    status ENUM('ACTIVE', 'WAITING', 'RESOLVED', 'CLOSED', 'ARCHIVED') DEFAULT 'ACTIVE',
    priority ENUM('LOW', 'NORMAL', 'HIGH', 'URGENT', 'CRITICAL') DEFAULT 'NORMAL',
    last_message_at DATETIME,
    unread_count INT DEFAULT 0,
    is_archived BOOLEAN DEFAULT FALSE,
    archived_at DATETIME,
    tags JSON,
    metadata JSON,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE SET NULL,
    
    INDEX idx_conversation_code (conversation_code),
    INDEX idx_conversation_type (conversation_type),
    INDEX idx_customer_id (customer_id),
    INDEX idx_assigned_to (assigned_to),
    INDEX idx_status (status),
    INDEX idx_priority (priority),
    INDEX idx_last_message_at (last_message_at),
    INDEX idx_is_archived (is_archived)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- TABLE: chat_messages
-- ========================================
CREATE TABLE IF NOT EXISTS chat_messages (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    conversation_id BIGINT NOT NULL,
    sender_id BIGINT NOT NULL,
    message_type ENUM('TEXT', 'IMAGE', 'FILE', 'AUDIO', 'VIDEO', 'LOCATION', 'SYSTEM', 'CALL_START', 'CALL_END', 'CALL_MISSED') DEFAULT 'TEXT',
    content TEXT,
    file_url VARCHAR(500),
    file_name VARCHAR(255),
    file_size BIGINT,
    file_type VARCHAR(100),
    is_read BOOLEAN DEFAULT FALSE,
    read_at DATETIME,
    read_by BIGINT,
    is_edited BOOLEAN DEFAULT FALSE,
    edited_at DATETIME,
    is_deleted BOOLEAN DEFAULT FALSE,
    deleted_at DATETIME,
    reply_to_message_id BIGINT,
    metadata JSON,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (conversation_id) REFERENCES chat_conversations(id) ON DELETE CASCADE,
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (read_by) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (reply_to_message_id) REFERENCES chat_messages(id) ON DELETE SET NULL,
    
    INDEX idx_conversation_id (conversation_id),
    INDEX idx_sender_id (sender_id),
    INDEX idx_message_type (message_type),
    INDEX idx_is_read (is_read),
    INDEX idx_is_deleted (is_deleted),
    INDEX idx_created_at (created_at),
    FULLTEXT INDEX idx_content (content)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- TABLE: chat_participants
-- ========================================
CREATE TABLE IF NOT EXISTS chat_participants (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    conversation_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    role ENUM('OWNER', 'ADMIN', 'MODERATOR', 'MEMBER', 'OBSERVER') DEFAULT 'MEMBER',
    joined_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    left_at DATETIME,
    is_active BOOLEAN DEFAULT TRUE,
    is_muted BOOLEAN DEFAULT FALSE,
    last_read_at DATETIME,
    unread_count INT DEFAULT 0,
    is_typing BOOLEAN DEFAULT FALSE,
    last_typing_at DATETIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (conversation_id) REFERENCES chat_conversations(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    UNIQUE KEY unique_conversation_user (conversation_id, user_id),
    INDEX idx_conversation_id (conversation_id),
    INDEX idx_user_id (user_id),
    INDEX idx_is_active (is_active),
    INDEX idx_is_typing (is_typing)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- TABLE: chat_attachments
-- ========================================
CREATE TABLE IF NOT EXISTS chat_attachments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    message_id BIGINT NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_url VARCHAR(500),
    file_size BIGINT,
    mime_type VARCHAR(100),
    attachment_type ENUM('IMAGE', 'VIDEO', 'AUDIO', 'DOCUMENT', 'ARCHIVE', 'OTHER'),
    thumbnail_url VARCHAR(500),
    duration_seconds INT,
    width INT,
    height INT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (message_id) REFERENCES chat_messages(id) ON DELETE CASCADE,
    
    INDEX idx_message_id (message_id),
    INDEX idx_attachment_type (attachment_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- TABLE: voip_calls
-- ========================================
CREATE TABLE IF NOT EXISTS voip_calls (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    call_id VARCHAR(100) UNIQUE NOT NULL,
    conversation_id BIGINT,
    caller_id BIGINT NOT NULL,
    callee_id BIGINT NOT NULL,
    call_type ENUM('AUDIO', 'VIDEO', 'SCREEN_SHARE') NOT NULL,
    call_status ENUM('INITIATED', 'RINGING', 'ANSWERED', 'BUSY', 'REJECTED', 'MISSED', 'ENDED', 'FAILED') DEFAULT 'INITIATED',
    started_at DATETIME,
    answered_at DATETIME,
    ended_at DATETIME,
    duration_seconds INT DEFAULT 0,
    end_reason ENUM('NORMAL', 'CALLER_HANGUP', 'CALLEE_HANGUP', 'TIMEOUT', 'NETWORK_ERROR', 'REJECTED', 'BUSY', 'CANCELLED'),
    recording_url VARCHAR(500),
    is_recorded BOOLEAN DEFAULT FALSE,
    quality_rating INT,
    ice_servers JSON,
    metadata JSON,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (conversation_id) REFERENCES chat_conversations(id) ON DELETE SET NULL,
    FOREIGN KEY (caller_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (callee_id) REFERENCES users(id) ON DELETE CASCADE,
    
    INDEX idx_call_id (call_id),
    INDEX idx_caller_id (caller_id),
    INDEX idx_callee_id (callee_id),
    INDEX idx_call_type (call_type),
    INDEX idx_call_status (call_status),
    INDEX idx_started_at (started_at),
    INDEX idx_is_recorded (is_recorded)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- VUES UTILES
-- ========================================

-- Vue pour les conversations actives avec dernier message
CREATE OR REPLACE VIEW v_active_conversations AS
SELECT 
    c.id,
    c.conversation_code,
    c.conversation_type,
    c.title,
    c.status,
    c.priority,
    c.last_message_at,
    c.unread_count,
    cu.company_name AS customer_name,
    u1.username AS created_by_username,
    u2.username AS assigned_to_username,
    (SELECT COUNT(*) FROM chat_participants WHERE conversation_id = c.id AND is_active = TRUE) AS participant_count,
    (SELECT COUNT(*) FROM chat_messages WHERE conversation_id = c.id) AS message_count
FROM chat_conversations c
LEFT JOIN customers cu ON c.customer_id = cu.id
LEFT JOIN users u1 ON c.created_by = u1.id
LEFT JOIN users u2 ON c.assigned_to = u2.id
WHERE c.is_archived = FALSE;

-- Vue pour les statistiques d'appels
CREATE OR REPLACE VIEW v_call_statistics AS
SELECT 
    caller_id,
    u1.username AS caller_username,
    COUNT(*) AS total_calls,
    SUM(CASE WHEN call_status = 'ANSWERED' THEN 1 ELSE 0 END) AS answered_calls,
    SUM(CASE WHEN call_status = 'MISSED' THEN 1 ELSE 0 END) AS missed_calls,
    SUM(CASE WHEN call_status = 'REJECTED' THEN 1 ELSE 0 END) AS rejected_calls,
    SUM(duration_seconds) AS total_duration_seconds,
    AVG(duration_seconds) AS avg_duration_seconds
FROM voip_calls v
JOIN users u1 ON v.caller_id = u1.id
GROUP BY caller_id, u1.username;

-- ========================================
-- DONNÉES DE TEST
-- ========================================

-- Insérer une conversation de test
INSERT INTO chat_conversations (conversation_code, conversation_type, title, created_by, status, priority)
VALUES ('CONV-TEST001', 'SUPPORT', 'Support Client - Test', 1, 'ACTIVE', 'NORMAL');

-- Insérer des participants
INSERT INTO chat_participants (conversation_id, user_id, role, is_active)
VALUES 
    (1, 1, 'OWNER', TRUE),
    (1, 2, 'MEMBER', TRUE);

-- Insérer un message de test
INSERT INTO chat_messages (conversation_id, sender_id, message_type, content)
VALUES (1, 1, 'TEXT', 'Bonjour, comment puis-je vous aider ?');

-- ========================================
-- TRIGGERS
-- ========================================

-- Trigger pour mettre à jour last_message_at
DELIMITER //
CREATE TRIGGER trg_update_last_message_at
AFTER INSERT ON chat_messages
FOR EACH ROW
BEGIN
    UPDATE chat_conversations
    SET last_message_at = NEW.created_at
    WHERE id = NEW.conversation_id;
END//
DELIMITER ;

-- Trigger pour incrémenter unread_count
DELIMITER //
CREATE TRIGGER trg_increment_unread_count
AFTER INSERT ON chat_messages
FOR EACH ROW
BEGIN
    UPDATE chat_participants
    SET unread_count = unread_count + 1
    WHERE conversation_id = NEW.conversation_id
    AND user_id != NEW.sender_id
    AND is_active = TRUE;
END//
DELIMITER ;

-- ========================================
-- COMMENTAIRES
-- ========================================
ALTER TABLE chat_conversations COMMENT = 'Conversations de chat (support, interne, client)';
ALTER TABLE chat_messages COMMENT = 'Messages de chat avec support multimédia';
ALTER TABLE chat_participants COMMENT = 'Participants des conversations';
ALTER TABLE chat_attachments COMMENT = 'Pièces jointes des messages';
ALTER TABLE voip_calls COMMENT = 'Appels VoIP (audio/vidéo)';

-- ========================================
-- FIN DU SCRIPT
-- ========================================

