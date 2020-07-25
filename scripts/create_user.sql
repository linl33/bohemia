USERNAME = 'joebrew'
PASSWORD = 'joebrew'
BASIC_AUTH_SALT = 'qwertyui'
REALM_STRING = "ODK Aggregate"

BASIC_AUTH_PASSWORD = SHA1( PASSWORD + "{" + BASIC_AUTH_SALT + "}" )
DIGEST_AUTH_PASSWORD = MD5( USERNAME + ":" + REALM_STRING + ":" + PASSWORD )

INSERT INTO aggregate._registered_users ()

INSERT INTO aggregate._user_granted_authority VALUES
('uuid:1eef8ee5-5c12-4781-a6b3-150d615b24f7', 'uid:administrator|2020-02-29T18:50:41.914Z', '2020-06-22 06:31:40.722', NULL, '2020-06-22 06:31:40.722', 'uid:data|2020-02-29T18:52:22.416Z', 'GROUP_SITE_ADMINS');

DELETE FROM aggregate._user_granted_authority WHERE '_URI'='uuid:1eef8ee5-5c12-4781-a6b3-150d615b24f6';
