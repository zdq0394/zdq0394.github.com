# Jenkins Access API
## User Credentials
### 创建Credentials

`POST /credentials/store/system/domain/_/createCredentials`

参数是JSON格式

`
{
		"": "0",
		"credentials": {
		"scope": "GLOBAL",
		"id": "{{.CredID}}",
		"username": "{{.UserName}}",
		"password": "{{.Password}}",
		"description": "{{.Description}}",
		"$class": "com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl"
		}
}
`

### 删除Credentials

`POST /credentials/store/system/domain/_/credential/<CREDENTIALS_ID>/doDelete`


### 查询Credentials

`GET /credentials/store/system/domain/api/xml?depth=1`

Request Headers:

Content-Type: application/xml
