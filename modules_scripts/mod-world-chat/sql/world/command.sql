DELETE FROM `command` WHERE name IN ('chat', 'chata', 'chath');

INSERT INTO `command` (`name`, `security`, `help`) VALUES 
('chata', 1, '语法: .chata $text - 以GM的身份向联盟发言'),
('chath', 1, '语法: .chath $text - 以GM的身份对部落说话'),
('chat', 0, '语法: .chat $text\n.chat on To show World Chat\n.chat off To hide World Chat');