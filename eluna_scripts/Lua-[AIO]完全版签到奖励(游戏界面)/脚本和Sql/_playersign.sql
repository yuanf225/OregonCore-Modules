
SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for _playersign
-- ----------------------------
DROP TABLE IF EXISTS `_playersign`;
CREATE TABLE `_playersign` (
  `guid` int(11) NOT NULL,
  `SignData` text NOT NULL,
  PRIMARY KEY (`guid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
