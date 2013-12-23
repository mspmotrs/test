
INSERT INTO `ticket_state_type` (`id`, `name`, `comments`, `create_time`, `create_by`, `change_time`, `change_by`)
VALUES
	(8, 'wind', 'State type for Wind integration ONLY', '2013-12-17 11:25:23', 1, '2013-12-17 11:25:23', 1);




INSERT INTO `ticket_state` (`id`, `name`, `comments`, `type_id`, `valid_id`, `create_time`, `create_by`, `change_time`, `change_by`)
VALUES
	(12, 'Sospeso', 'Stato valido solo per l\'integrazione con Wind', 8, 1, '2013-12-17 16:14:10', 1, '2013-12-17 16:14:10', 1),
	(13, 'RisoltoNRI', '(Non RIscontrato) Stato valido solo per l\'integrazione con Wind', 8, 1, '2013-12-17 16:15:37', 1, '2013-12-17 16:15:37', 1),
	(14, 'RisoltoNoACT', '(No ACTion) Stato valido solo per l\'integrazione con Wind', 8, 1, '2013-12-17 16:16:28', 1, '2013-12-17 16:16:28', 1);




INSERT INTO `ticket_type` (`id`, `name`, `valid_id`, `create_time`, `create_by`, `change_time`, `change_by`)
VALUES
	(53, 'Incident per WIND', 1, '2013-12-17 16:46:26', 1, '2013-12-17 16:46:26', 1),
	(54, 'Incident per PM', 1, '2013-12-17 16:47:00', 1, '2013-12-17 16:47:00', 1),
	(55, 'Incident per ERICSSON', 1, '2013-12-17 16:47:15', 1, '2013-12-17 16:47:15', 1),
	(56, 'Alarm per WIND', 1, '2013-12-17 16:47:52', 1, '2013-12-17 16:47:52', 1),
	(57, 'Alarm per ERICSSON', 1, '2013-12-17 16:48:17', 1, '2013-12-17 16:48:17', 1),
	(58, 'Alarm per PM', 1, '2013-12-17 16:48:34', 1, '2013-12-17 16:48:34', 1),
	(59, 'Alarm da WIND', 1, '2013-12-17 16:49:03', 1, '2013-12-17 16:49:03', 1);





INSERT INTO `article_type` (`id`, `name`, `comments`, `valid_id`, `create_time`, `create_by`, `change_time`, `change_by`)
VALUES
	(17, 'note-external-ToWind', NULL, 1, '2013-12-17 16:40:38', 1, '2013-12-17 16:40:38', 1),
	(18, 'note-external-FromWind', NULL, 1, '2013-12-17 16:41:25', 1, '2013-12-17 16:41:25', 1);





INSERT INTO `groups` (`id`, `name`, `comments`, `valid_id`, `create_time`, `create_by`, `change_time`, `change_by`)
VALUES
	(79, '_full_Ericsson_create', 'Ambito FULL (Integrazione con Wind)', 1, '2013-12-17 18:32:34', 1, '2013-12-17 18:32:34', 1),
	(80, '_full_Ericsson_backend', 'Ambito FULL (Integrazione con Wind)', 1, '2013-12-17 18:33:54', 1, '2013-12-17 18:33:54', 1),
	(81, '_full_Ericsson_Alarm_For_PM', 'Ambito FULL (Integrazione con Wind)', 1, '2013-12-17 18:34:18', 1, '2013-12-17 18:34:18', 1),
	(82, '_full_Ericsson_Alarm_For_Wind', 'Ambito FULL (Integrazione con Wind)', 1, '2013-12-17 18:34:39', 1, '2013-12-17 18:34:39', 1),
	(83, '_full_PM_create', 'Ambito FULL (Integrazione con Wind)', 1, '2013-12-17 18:35:06', 1, '2013-12-17 18:46:08', 1),
	(84, '_full_PM_Incident_For_Wind', 'Ambito FULL (Integrazione con Wind)', 1, '2013-12-17 18:35:54', 1, '2013-12-17 18:35:54', 1),
	(85, '_full_Wind_Alarm_For_PM', 'Ambito FULL (Integrazione con Wind)', 1, '2013-12-17 18:36:18', 1, '2013-12-17 18:36:18', 1),
	(86, '_full_PM_Incident_For_Wind_and_Ericsson', 'Ambito FULL (Integrazione con Wind)', 1, '2013-12-17 18:36:43', 1, '2013-12-17 18:36:43', 1),
	(87, '_full_PM_Alarm_For_Ericsson', 'Ambito FULL (Integrazione con Wind)', 1, '2013-12-17 18:37:05', 1, '2013-12-17 18:37:05', 1),
	(88, '_full_PM_Alarm_For_Wind', 'Ambito FULL (Integrazione con Wind)', 1, '2013-12-17 18:37:28', 1, '2013-12-17 18:37:28', 1),
	(89, '_full_PM_Alarm_For_Wind_and_Ericsson', 'Ambito FULL (Integrazione con Wind)', 1, '2013-12-17 18:38:01', 1, '2013-12-17 18:38:01', 1),
	(90, '_full_Wind_Alarm_For_PM_and_Ericsson', 'Ambito FULL (Integrazione con Wind)', 1, '2013-12-17 18:38:21', 1, '2013-12-17 18:38:21', 1),
	(91, '_full_Ericsson_Incident_For_PM', 'Ambito FULL (Integrazione con Wind)', 1, '2013-12-17 18:38:52', 1, '2013-12-17 18:38:52', 1);





INSERT INTO `queue` (`id`, `name`, `group_id`, `unlock_timeout`, `first_response_time`, `first_response_notify`, `update_time`, `update_notify`, `solution_time`, `solution_notify`, `system_address_id`, `calendar_name`, `default_sign_key`, `salutation_id`, `signature_id`, `follow_up_id`, `follow_up_lock`, `comments`, `valid_id`, `create_time`, `create_by`, `change_time`, `change_by`)
VALUES
	(1017, 'ERICSSON-Create', 79, 0, 0, 0, 0, 0, 0, 0, 1, '0', '0', 1, 1, 1, 0, 'Ambito FULL (Integrazione con Wind)', 1, '2013-12-17 18:40:17', 1, '2013-12-17 18:40:17', 1),
	(1018, 'ERICSSON-BackEnd', 80, 0, 0, 0, 0, 0, 0, 0, 1, '0', '0', 1, 1, 1, 0, 'Ambito FULL (Integrazione con Wind)', 1, '2013-12-17 18:41:30', 1, '2013-12-17 18:41:30', 1),
	(1019, 'MVNE-FE-Ericsson-Alarm', 81, 0, 0, 0, 0, 0, 0, 0, 1, '0', '0', 1, 1, 1, 0, 'Ambito FULL (Integrazione con Wind)', 1, '2013-12-17 18:42:48', 1, '2013-12-17 18:42:48', 1),
	(1020, 'ERICSSON-WIND-OUT-Alarm', 82, 0, 0, 0, 0, 0, 0, 0, 1, '0', '0', 1, 1, 1, 0, 'Ambito FULL (Integrazione con Wind)', 1, '2013-12-17 18:44:44', 1, '2013-12-17 18:44:44', 1),
	(1021, 'PM-Create', 83, 0, 0, 0, 0, 0, 0, 0, 1, '0', '0', 1, 1, 1, 0, 'Ambito FULL (Integrazione con Wind)', 1, '2013-12-17 18:46:44', 1, '2013-12-17 18:46:44', 1),
	(1022, 'WIND_OUT', 84, 0, 0, 0, 0, 0, 0, 0, 1, '0', '0', 1, 1, 1, 0, 'Ambito FULL (Integrazione con Wind)', 1, '2013-12-17 18:47:17', 1, '2013-12-17 18:47:17', 1),
	(1023, 'MVNE-FE-Wind-Alarm', 85, 0, 0, 0, 0, 0, 0, 0, 1, '0', '0', 1, 1, 1, 0, 'Ambito FULL (Integrazione con Wind)', 1, '2013-12-17 18:47:52', 1, '2013-12-17 18:47:52', 1),
	(1024, 'ERICSSON_PM_WIND_OUT', 86, 0, 0, 0, 0, 0, 0, 0, 1, '0', '0', 1, 1, 1, 0, 'Ambito FULL (Integrazione con Wind)', 1, '2013-12-17 18:49:18', 1, '2013-12-17 18:49:18', 1),
	(1025, 'ERICSSON-OUT-Alarm', 87, 0, 0, 0, 0, 0, 0, 0, 1, '0', '0', 1, 1, 1, 0, 'Ambito FULL (Integrazione con Wind)', 1, '2013-12-17 18:50:02', 1, '2013-12-17 18:50:02', 1),
	(1026, 'WIND_OUT_Alarm', 88, 0, 0, 0, 0, 0, 0, 0, 1, '0', '0', 1, 1, 1, 0, 'Ambito FULL (Integrazione con Wind)', 1, '2013-12-17 18:50:42', 1, '2013-12-17 18:50:42', 1),
	(1027, 'WIND-ERICSSON-OUT-Alarm', 89, 0, 0, 0, 0, 0, 0, 0, 1, '0', '0', 1, 1, 1, 0, 'Ambito FULL (Integrazione con Wind)', 1, '2013-12-17 18:51:32', 1, '2013-12-17 18:51:32', 1),
	(1028, 'MVNE-FE-Wind-Ericsson-Alarm', 90, 0, 0, 0, 0, 0, 0, 0, 1, '0', '0', 1, 1, 1, 0, 'Ambito FULL (Integrazione con Wind)', 1, '2013-12-17 18:52:11', 1, '2013-12-17 18:52:11', 1),
	(1029, 'MVNE-FE-Ericsson-Incident', 91, 0, 0, 0, 0, 0, 0, 0, 1, '0', '0', 1, 1, 1, 0, 'Ambito FULL (Integrazione con Wind)', 1, '2013-12-17 18:52:50', 1, '2013-12-17 18:52:50', 1);













