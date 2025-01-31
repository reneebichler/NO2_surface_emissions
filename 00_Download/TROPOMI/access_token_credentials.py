## ------------------------------------------------------------------------------------
## Libraries
## ------------------------------------------------------------------------------------

## Source: https://gist.github.com/willrayeo/8aa424384f272d3003a2dea6460cb07b#file-keychain_credentials-py (last access: 5th Nov. 2024)

## Import credentials
import requests
import getpass

## ------------------------------------------------------------------------------------
## Functions
## ------------------------------------------------------------------------------------

class Token:

    def get_access_token(username: str, password: str) -> str:
        data = {
            "client_id": "cdse-public",
            "username": username,
            "password": password,
            "grant_type": "password",
        }
        try:
            r = requests.post(
                "https://identity.dataspace.copernicus.eu/auth/realms/CDSE/protocol/openid-connect/token",
                data=data,
            )
            r.raise_for_status()
        except Exception as e:
            raise Exception(
                f"Access token creation failed. Reponse from the server was: {r.json()}"
            )
        return r.json()["access_token"]

    def get_user_pw(self):

        access_token = Token.get_access_token("renee.bichler@outlook.com", "ESAnasadlr#1")
        return(access_token)

        #access_token = Token.get_access_token(
        #    getpass.getpass("username: "),
        #    getpass.getpass("password: "),
        #)

        #print(access_token)