export AWS_PROFILE="nina"
USER_POOL

aws cognito-idp admin-create-user \
--user-pool-id SEU_USER_POOL_ID \
--username "srp-user" \
--user-attributes Name="email",Value="srp@exemplo.com" \
--temporary-password "SenhaParaSRP123!" \
--message-action SUPPRESS \