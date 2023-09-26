#!/bin/sh
# Script to upload all default certificates for a sandbox setup. The following are uploaded:
# Export these environment variables on command line
#URL={{base_url of the environment}}
#CERT_MANAGER_PASSWORD={{secretkey of mosip-deployment-client}}
# Usage: ./default.sh
# See HTML reports under ./reports folder

upload_ida_root_cert() {
    echo "Uploading ida root cert"
    newman run onboarding.postman_collection.json --delay-request 2000 -e onboarding.postman_environment.json --bail \
    --env-var url="$URL" \
    --env-var cert-application-id=ROOT \
    --env-var cert-reference-id=  \
    --env-var request-time="$DATE" \
    --env-var cert-manager-username="$KEYCLOAK_CLIENT" \
    --env-var cert-manager-password="$KEYCLOAK_CLIENT_SECRET" \
    --env-var partner-domain=AUTH \
    --folder authenticate-as-cert-manager \
    --folder download-ida-certificate \
    --folder upload-ca-certificate \
    $ADD_SSL_NEWMAN \
	  -r cli,htmlextra --reporter-htmlextra-export ./reports/ida-root.html

}

upload_ida_cert() {
    echo "Uploading ida cert"
    newman run onboarding.postman_collection.json --delay-request 2000 -e onboarding.postman_environment.json --bail \
    --env-var url="$URL" \
    --env-var cert-application-id=IDA \
    --env-var cert-reference-id=  \
    --env-var request-time="$DATE" \
    --env-var cert-manager-username="$KEYCLOAK_CLIENT" \
    --env-var cert-manager-password="$KEYCLOAK_CLIENT_SECRET" \
    --env-var partner-domain=AUTH \
    --folder authenticate-as-cert-manager \
    --folder download-ida-certificate \
    --folder upload-ca-certificate \
    $ADD_SSL_NEWMAN \
    -r cli,htmlextra --reporter-htmlextra-export ./reports/ida-ca.html
}

upload_ida_partner_cert () {
    echo "Uploading mpartner-default-auth cert"
    newman run onboarding.postman_collection.json --delay-request 2000 -e onboarding.postman_environment.json --bail \
    --env-var url="$URL" \
    --env-var request-time="$DATE" \
    --env-var cert-application-id=IDA \
    --env-var cert-reference-id=mpartner-default-auth \
    --env-var cert-manager-username="$KEYCLOAK_CLIENT" \
    --env-var cert-manager-password="$KEYCLOAK_CLIENT_SECRET" \
    --env-var keycloak-admin-username="$KEYCLOAK_ADMIN_USER" \
    --env-var keycloak-admin-password="$KEYCLOAK_ADMIN_PASSWORD" \
    --env-var partner-kc-username=mpartner-default-auth \
    --env-var partner-domain=AUTH \
    --folder authenticate-as-cert-manager \
    --folder download-ida-certificate \
    --folder upload-leaf-certificate \
    --folder upload-signed-leaf-certificate \
    $ADD_SSL_NEWMAN \
    -r cli,htmlextra --reporter-htmlextra-export ./reports/ida-partner.html --reporter-htmlextra-showEnvironmentData
}

upload_ida_cred_cert () {
    echo "Uploading ida cred cert to keymanager for zero knowledge encryption"
    newman run onboarding.postman_collection.json --delay-request 2000 -e onboarding.postman_environment.json --bail \
    --env-var url="$URL" \
    --env-var request-time="$DATE" \
    --env-var cert-application-id=IDA \
    --env-var cert-reference-id=CRED_SERVICE \
    --env-var cert-manager-username="$KEYCLOAK_CLIENT" \
    --env-var cert-manager-password="$KEYCLOAK_CLIENT_SECRET" \
    --env-var partner-kc-username=mpartner-default-auth \
    --env-var partner-domain=AUTH \
    --folder authenticate-as-cert-manager \
    --folder download-ida-certificate \
    --folder upload-ida-cred-cert-to-keymanager \
    $ADD_SSL_NEWMAN \
    -r cli,htmlextra --reporter-htmlextra-export ./reports/ida-cred.html --reporter-htmlextra-showEnvironmentData
}

upload_resident_cert() {
    echo "Uploading mpartner-default-resident cert"
    newman run onboarding.postman_collection.json --delay-request 2000 -e onboarding.postman_environment.json --bail \
    --env-var url="$URL" \
    --env-var request-time="$DATE" \
    --env-var cert-application-id=RESIDENT \
    --env-var cert-reference-id=mpartner-default-resident \
    --env-var cert-manager-username="$KEYCLOAK_CLIENT" \
    --env-var cert-manager-password="$KEYCLOAK_CLIENT_SECRET" \
    --env-var keycloak-admin-username="$KEYCLOAK_ADMIN_USER" \
    --env-var keycloak-admin-password="$KEYCLOAK_ADMIN_PASSWORD" \
    --env-var partner-kc-username=mpartner-default-resident \
    --env-var partner-domain=AUTH \
    --folder authenticate-as-cert-manager \
    --folder download-intermediate-resident-certificate-from-keymanager \
    --folder download-leaf-certificate-from-keymanager \
    --folder upload-intermediate-ca-certificate \
    --folder upload-leaf-certificate \
    --folder upload-signed-leaf-certifcate-to-keymanager \
    $ADD_SSL_NEWMAN \
    -r cli,htmlextra --reporter-htmlextra-export ./reports/resident.html --reporter-htmlextra-showEnvironmentData
}
upload_print_cert() {
    echo "Uploading mpartner-default-print cert"
    root_cert_path="$MYDIR/certs/print/root-ca-inline.pem"
    partner_cert_path="$MYDIR/certs/print/client-inline.pem"
    root_ca_cert=`awk '{ print $0 }' $root_cert_path`
    partner_cert=`awk '{ print $0 }' $partner_cert_path`
    newman run onboarding.postman_collection.json --delay-request 2000 -e onboarding.postman_environment.json --bail \
    --env-var url="$URL" \
    --env-var request-time="$DATE" \
    --env-var cert-manager-username="$KEYCLOAK_CLIENT" \
    --env-var cert-manager-password="$KEYCLOAK_CLIENT_SECRET" \
    --env-var partner-kc-username=mpartner-default-print \
    --env-var application-id=ida \
    --env-var partner-domain=AUTH \
    --env-var ca-certificate="$root_ca_cert" \
    --env-var leaf-certificate="$partner_cert" \
    --folder authenticate-as-cert-manager \
    --folder upload-ca-certificate \
    --folder upload-leaf-certificate \
    $ADD_SSL_NEWMAN \
    -r cli,htmlextra --reporter-htmlextra-export ./reports/print.html --reporter-htmlextra-showEnvironmentData
}

upload_abis_cert () {
    echo "Uploading mpartner-default-abis cert"
    root_cert_path="$MYDIR/certs/abis/root-ca-inline.pem"
    partner_cert_path="$MYDIR/certs/abis/client-inline.pem"
    root_ca_cert=`awk '{ print $0 }' $root_cert_path`
    partner_cert=`awk '{ print $0 }' $partner_cert_path`
    newman run onboarding.postman_collection.json --delay-request 2000 -e onboarding.postman_environment.json --bail \
    --env-var url="$URL" \
    --env-var request-time="$DATE" \
    --env-var cert-manager-username="$KEYCLOAK_CLIENT" \
    --env-var cert-manager-password="$KEYCLOAK_CLIENT_SECRET" \
    --env-var partner-kc-username=mpartner-default-abis \
    --env-var application-id=ida \
    --env-var partner-domain=AUTH \
    --env-var ca-certificate="$root_ca_cert" \
    --env-var leaf-certificate="$partner_cert" \
    --folder authenticate-as-cert-manager \
    --folder upload-ca-certificate \
    --folder upload-leaf-certificate \
    $ADD_SSL_NEWMAN \
    -r cli,htmlextra --reporter-htmlextra-export ./reports/abis.html --reporter-htmlextra-showEnvironmentData
}
upload_mpartner_default_mobile_cert() {
    echo "Uploading mpartner-default-mobile cert"
    root_cert_path="$MYDIR/certs/mpartner-default-mobile/root-ca-inline.pem"
    partner_cert_path="$MYDIR/certs/mpartner-default-mobile/client-inline.pem"
    root_ca_cert=`awk '{ print $0 }' $root_cert_path`
    partner_cert=`awk '{ print $0 }' $partner_cert_path`
    newman run onboarding.postman_collection.json --delay-request 2000 -e onboarding.postman_environment.json --bail \
    --env-var url="$URL" \
    --env-var request-time="$DATE" \
    --env-var cert-manager-username="$KEYCLOAK_CLIENT" \
    --env-var cert-manager-password="$KEYCLOAK_CLIENT_SECRET" \
    --env-var partner-kc-username=mpartner-default-mobile \
    --env-var application-id=ida \
    --env-var partner-domain=AUTH \
    --env-var policy-name=mpolicy-default-mobile \
    --env-var credential-type=vercred \
    --env-var ca-certificate="$root_ca_cert" \
    --env-var leaf-certificate="$partner_cert" \
    --folder authenticate-as-cert-manager \
    --folder upload-ca-certificate \
    --folder upload-leaf-certificate \
    --folder mapping-partner-to-policy-credential-type \
    $ADD_SSL_NEWMAN \
    -r cli,htmlextra --reporter-htmlextra-export ./reports/mpartner-default-mobile.html --reporter-htmlextra-showEnvironmentData
}
upload_mpartner_default_digitalcard_cert() {
    echo "Uploading mpartner-default-digitalcard cert"
    newman run onboarding.postman_collection.json --delay-request 2000 -e onboarding.postman_environment.json --bail \
    --env-var url="$URL" \
    --env-var request-time="$DATE" \
    --env-var cert-application-id=DIGITAL_CARD \
    --env-var cert-reference-id=mpartner-default-digitalcard \
    --env-var cert-manager-username="$KEYCLOAK_CLIENT" \
    --env-var cert-manager-password="$KEYCLOAK_CLIENT_SECRET" \
    --env-var keycloak-admin-username="$KEYCLOAK_ADMIN_USER" \
    --env-var keycloak-admin-password="$KEYCLOAK_ADMIN_PASSWORD" \
    --env-var partner-kc-username=mpartner-default-digitalcard \
    --env-var partner-domain=AUTH \
    --folder authenticate-as-cert-manager \
    --folder download-intermediate-resident-certificate-from-keymanager \
    --folder download-leaf-certificate-from-keymanager \
    --folder upload-intermediate-ca-certificate \
    --folder upload-leaf-certificate \
    --folder upload-signed-leaf-certifcate-to-keymanager \
    $ADD_SSL_NEWMAN \
    -r cli,htmlextra --reporter-htmlextra-export ./reports/digitalcard.html --reporter-htmlextra-showEnvironmentData
}

onboard_esignet_partner() {
    echo "Onboarding esignet-partner"
    newman run onboarding.postman_collection.json --delay-request 2000 -e onboarding.postman_environment.json --bail \
    --env-var url="$URL" \
    --env-var request-time="$DATE" \
	--env-var partner-manager-username=esignet-kc-mockusername \
	--env-var partner-manager-password=esignet-kc-mockpassword \
	--env-var application-id=$APPLICATION_ID \
	--env-var module-clientid=$MODULE_CLIENTID \
	--env-var module-secretkey=$MODULE_SECRETKEY \
	--env-var policy-group-name=$POLICY_GROUP_NAME \
	--env-var partner-kc-username=$PARTNER_KC_USERNAME \
	--env-var partner-organization-name=$PARTNER_ORGANIZATION_NAME \
    --env-var partner-type=$PARTNER_TYPE \
    --env-var external-url=$EXTERNAL_URL \
	--env-var policy-name=$POLICY_NAME \
	--env-var keycloak-url=$KEYCLOAK_URL \
	--env-var keycloak-admin-password="$KEYCLOAK_ADMIN_PASSWORD" \
	--env-var keycloak-admin-username=$KEYCLOAK_ADMIN_USER \
	--env-var partner-domain=MISP \
	--folder 'create_keycloak_user' \
	--folder 'create/publish_policy_group_and_policy' \
	--folder partner-self-registration \
    --folder download-esignet-root-certificate \
    --folder download-esignet-leaf-certificate \
	--folder download-esignet-partner-certificate \
	--folder authenticate-to-upload-certs \
    --folder upload-ca-certificate \
	--folder upload-intermediate-ca-certificate  \
    --folder upload-leaf-certificate \
    --folder activate-partner \
	--folder upload-signed-esignet-certificate \
	--folder partner_request_mapping_to_policyname \
	--folder approve-partner-mapping-to-policy \
	--folder create-the-MISP-license-key-for-partner \
	--folder login-to-keycloak-as-admin \
	--folder delete-user \
    $ADD_SSL_NEWMAN \
    --export-environment ./config-secrets.json -d ./default-misp-policy.json -r cli,htmlextra --reporter-htmlextra-export ./reports/e-signet.html --reporter-htmlextra-showEnvironmentData
    MISP_LICENSE_KEY=$(jq -r '.values[] | select(.key == "mpartner-default-esignet-misp-license-key") | .value' config-secrets.json)

if [ -z "$MISP_LICENSE_KEY" ]; then
    MISP_LICENSE_KEY=$(jq -r '.values[] | select(.key | contains("mpartner-default-esignet-misp-license-key")) | .value' config-secrets.json)
fi
echo "MISP License Key: $MISP_LICENSE_KEY"
}

onboard_relying_party_with_demo_oidc_client(){
    echo "Onboarding demo-oidc-client"
	sh $MYDIR/certs/create-signing-certs.sh $MYDIR
	root_ca_cert=$(awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' $root_cert_path)
	partner_cert=$(awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' $client_cert_path)
	echo $root_ca_cert
	echo $partner_cert
	newman run onboarding.postman_collection.json --delay-request 2000 -e onboarding.postman_environment.json --bail \
    --env-var url="$URL" \
    --env-var request-time="$DATE" \
	--env-var partner-manager-username=demooidc-kc-mockusername \
	--env-var partner-manager-password=demooidc-kc-mockuserpassword \
	--env-var application-id=$APPLICATION_ID \
	--env-var module-clientid=$MODULE_CLIENTID \
	--env-var module-secretkey=$MODULE_SECRETKEY \
	--env-var policy-group-name=$POLICY_GROUP_NAME \
	--env-var partner-kc-username=$PARTNER_KC_USERNAME \
	--env-var partner-organization-name=$PARTNER_ORGANIZATION_NAME \
    --env-var partner-type=$PARTNER_TYPE \
    --env-var external-url=$EXTERNAL_URL \
	--env-var policy-name=$POLICY_NAME \
	--env-var logo-uri=$LOGO_URI \
	--env-var redirect-uri=$REDIRECT_URI \
	--env-var keycloak-url=$KEYCLOAK_URL \
	--env-var keycloak-admin-password=$KEYCLOAK_ADMIN_PASSWORD \
	--env-var keycloak-admin-username=$KEYCLOAK_ADMIN_USERNAME \
	--env-var cert-manager-username="$KEYCLOAK_CLIENT" \
    --env-var cert-manager-password="$KEYCLOAK_CLIENT_SECRET" \
	--env-var partner-domain=Auth \
	--env-var ca-certificate="$root_ca_cert" \
	--env-var leaf-certificate="$partner_cert" \
	--env-var oidc-client-name="$OIDC_CLIENT_NAME" \
	--folder 'create_keycloak_user' \
	--folder 'create/publish_policy_group_and_policy' \
	--folder partner-self-registration \
	--folder authenticate-to-upload-certs \
    --folder upload-ca-certificate \
    --folder upload-leaf-certificate \
    --folder activate-partner \
	--folder partner_request_mapping_to_policyname \
	--folder approve-partner-mapping-to-policy \
	--folder get-jwks \
	--folder create-oidc-client \
	--folder delete-user \
    $ADD_SSL_NEWMAN \
    --export-environment ./config-secrets.json -d ./oidc-policy.json -r cli,htmlextra --reporter-htmlextra-export ./reports/demo-oidc.html --reporter-htmlextra-showEnvironmentData
privateandpublickeypair=$(jq -r '.values[] | select(.key == "privateandpublickeypair") | .value' config-secrets.json)
privateandpublickeypair=$(echo -n "$privateandpublickeypair" | base64)
mpartnerdefaultdemooidcclientID=$(jq -r '.values[] | select(.key == "mpartner-default-demo-oidc-clientID") | .value' "config-secrets.json")
echo "Private and Public KeyPair: $privateandpublickeypair"
echo "mpartner default demo OIDC clientId:$mpartnerdefaultdemooidcclientID"
}
onboard_resident_oidc_client() {
echo "Onboarding resident oidc client"
    sh $MYDIR/certs/create-jwks.sh
    if [ $? -gt 0 ]; then
      echo "JWK Key generation failed; EXITING";
      exit 1;
    fi
    echo "JWK Keys generated successfully"
    jwk_key=$(awk -F'"' '/"n"/ {print $8}' pubkey.jwk)
    newman run onboarding.postman_collection.json --delay-request 2000 -e onboarding.postman_environment.json --bail \
    --env-var url=$URL \
    --env-var request-time=$DATE \
	--env-var partner-manager-username=residentoidc-kc-mockusername \
	--env-var partner-manager-password=residentoidc-kc-mockuserpassword \
	--env-var application-id=$APPLICATION_ID \
	--env-var module-clientid=$MODULE_CLIENTID \
	--env-var module-secretkey=$MODULE_SECRETKEY \
	--env-var policy-group-name=$POLICY_GROUP_NAME \
	--env-var partner-kc-username=$PARTNER_KC_USERNAME \
	--env-var partner-organization-name=$PARTNER_ORGANIZATION_NAME \
    --env-var partner-type=$PARTNER_TYPE \
	--env-var partner-domain=Auth \
    --env-var external-url=$EXTERNAL_URL \
	--env-var policy-name=$POLICY_NAME \
	--env-var keycloak-url=$KEYCLOAK_URL \
	--env-var keycloak-admin-password=$KEYCLOAK_ADMIN_PASSWORD \
	--env-var keycloak-admin-username=$KEYCLOAK_ADMIN_USERNAME \
	--env-var cert-manager-username="$KEYCLOAK_CLIENT" \
    --env-var cert-manager-password="$KEYCLOAK_CLIENT_SECRET" \
	--env-var cert-application-id=RESIDENT \
    --env-var cert-reference-id=ESIGNET_USER_INFO \
	--env-var key="$jwk_key" \
	--env-var oidc-client-name=$OIDC_CLIENT_NAME \
	--env-var logo-uri=$LOGO_URI \
	--env-var redirect-uri=$REDIRECT_URI \
	--folder 'create_keycloak_user' \
	--folder 'create/publish_policy_group_and_policy' \
	--folder partner-self-registration \
	--folder authenticate-as-cert-manager \
	--folder download-ca-certificate-from-keymanager \
	--folder download-intermediate-resident-certificate-from-keymanager \
    --folder download-leaf-certificate-from-keymanager \
	--folder authenticate-to-upload-certs \
    --folder upload-ca-certificate \
	--folder upload-intermediate-ca-certificate  \
    --folder upload-leaf-certificate \
	--folder partner_request_mapping_to_policyname \
	--folder approve-partner-mapping-to-policy \
	--folder login-to-keycloak-as-admin \
	--folder get-keyid-from-keymanager \
	--folder create-oidc-client \
	--folder delete-user \
	$ADD_SSL_NEWMAN \
    --export-environment ./config-secrets.json -d ./oidc-policy.json -r cli,htmlextra --reporter-htmlextra-export ./reports/resident-oidc.html --reporter-htmlextra-showEnvironmentData
mpartnerdefaultresidentoidcclientID=$(jq -r '.values[] | select(.key == "mpartner-default-resident-oidc-clientID") | .value' "config-secrets.json")
echo "mpartner default resident OIDC clientId: $mpartnerdefaultresidentoidcclientID"
}
onboard_mimoto_keybinding_partner(){
    echo "Onboarding Mimoto Keybinding partner"
	sh $MYDIR/certs/create-signing-certs.sh $MYDIR
	root_ca_cert=$(awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' $root_cert_path)
	partner_cert=$(awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' $client_cert_path)
	echo $root_ca_cert
	echo $partner_cert
	newman run onboarding.postman_collection.json --delay-request 2000 -e onboarding.postman_environment.json --bail \
  --env-var url="$URL" \
  --env-var request-time="$DATE" \
	--env-var partner-manager-username=$PARTNER_KC_USERNAME \
	--env-var partner-manager-password=$PARTNER_KC_USERPASSWORD \
	--env-var application-id=$APPLICATION_ID \
	--env-var module-clientid=$MODULE_CLIENTID \
	--env-var module-secretkey=$MODULE_SECRETKEY \
	--env-var policy-group-name=$POLICY_GROUP_NAME \
	--env-var partner-kc-username=$PARTNER_KC_USERNAME \
	--env-var partner-kc-userpassword=$PARTNER_KC_USERPASSWORD \
	--env-var partner-organization-name=$PARTNER_ORGANIZATION_NAME \
  --env-var partner-type=$PARTNER_TYPE \
  --env-var policy-name=$POLICY_NAME \
	--env-var keycloak-url=$KEYCLOAK_URL \
	--env-var keycloak-admin-password=$KEYCLOAK_ADMIN_PASSWORD \
	--env-var keycloak-admin-username=$KEYCLOAK_ADMIN_USERNAME \
	--env-var cert-manager-username="$KEYCLOAK_CLIENT" \
  --env-var cert-manager-password="$KEYCLOAK_CLIENT_SECRET" \
	--env-var partner-domain=Auth \
	--env-var ca-certificate="$root_ca_cert" \
	--env-var leaf-certificate="$partner_cert" \
	--folder 'create_keycloak_user' \
	--folder 'create/publish_policy_group_and_policy' \
	--folder partner-self-registration \
	--folder authenticate-to-upload-certs \
  --folder upload-ca-certificate \
  --folder upload-leaf-certificate \
	--folder partner_request_mapping_to_policyname \
	--folder approve-partner-mapping-to-policy \
	--folder authenticate-as-partner-for-api-key \
	--folder request-for-partner-apikey \
	--folder delete-user \
    $ADD_SSL_NEWMAN \
    --export-environment ./config-secrets.json -d ./oidc-policy.json -r cli,htmlextra --reporter-htmlextra-export ./reports/mimoto-keybinding.html --reporter-htmlextra-showEnvironmentData
mpartnerdefaultmimotokeybindingapikey=$(jq -r '.values[] | select(.key == "mpartner-default-mimotokeybinding-apikey") | .value' "config-secrets.json")
echo "mpartner default mimoto keybinding apikey: $mpartnerdefaultmimotokeybindingapikey"
}
onboard_mimoto_oidc_partner(){
    echo "Onboarding Mimoto OIDC partner"
	sh $MYDIR/certs/create-signing-certs.sh $MYDIR
	root_ca_cert=$(awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' $root_cert_path)
	partner_cert=$(awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' $client_cert_path)
	sh $MYDIR/certs/convert.sh $MYDIR
	if [ $? -gt 0 ]; then
      echo "JWK Key generation failed; EXITING";
      exit 1;
    fi
    echo "JWK Keys generated successfully"
    jwk_key=$(awk -F'"' '/"n"/ {print $8}' $MYDIR/certs/$PARTNER_KC_USERNAME/publickey.jwk)
	echo $jwk_key
	newman run onboarding.postman_collection.json --delay-request 2000 -e onboarding.postman_environment.json --bail \
  --env-var url="$URL" \
  --env-var request-time="$DATE" \
	--env-var partner-manager-username=$PARTNER_KC_USERNAME \
	--env-var partner-manager-password=$PARTNER_KC_USERPASSWORD \
	--env-var logo-uri=$LOGO_URI \
	--env-var redirect-uri=$REDIRECT_URI \
	--env-var application-id=$APPLICATION_ID \
	--env-var module-clientid=$MODULE_CLIENTID \
	--env-var module-secretkey=$MODULE_SECRETKEY \
	--env-var policy-group-name=$POLICY_GROUP_NAME \
	--env-var partner-kc-username=$PARTNER_KC_USERNAME \
	--env-var partner-kc-userpassword=$PARTNER_KC_USERPASSWORD \
	--env-var partner-organization-name=$PARTNER_ORGANIZATION_NAME \
  --env-var partner-type=$PARTNER_TYPE \
	--env-var key="$jwk_key" \
	--env-var keyid="" \
  --env-var policy-name=$POLICY_NAME \
	--env-var keycloak-url=$KEYCLOAK_URL \
	--env-var keycloak-admin-password=$KEYCLOAK_ADMIN_PASSWORD \
	--env-var keycloak-admin-username=$KEYCLOAK_ADMIN_USERNAME \
	--env-var cert-manager-username="$KEYCLOAK_CLIENT" \
  --env-var cert-manager-password="$KEYCLOAK_CLIENT_SECRET" \
	--env-var partner-domain=Auth \
	--env-var oidc-client-name="$OIDC_CLIENT_NAME" \
	--env-var ca-certificate="$root_ca_cert" \
	--env-var leaf-certificate="$partner_cert" \
	--folder 'create_keycloak_user' \
	--folder 'create/publish_policy_group_and_policy' \
	--folder partner-self-registration \
	--folder authenticate-to-upload-certs \
  --folder upload-ca-certificate \
  --folder upload-leaf-certificate \
	--folder partner_request_mapping_to_policyname \
	--folder approve-partner-mapping-to-policy \
	--folder create-oidc-client \
	--folder delete-user \
    $ADD_SSL_NEWMAN \
  --export-environment ./config-secrets.json -d ./oidc-policy.json -r cli,htmlextra --reporter-htmlextra-export ./reports/mimoto-oidc.html --reporter-htmlextra-showEnvironmentData
}

## Script starts from here
export MYDIR=$(pwd)
DATE=$(date -u +%FT%T.%3NZ)
KEYCLOAK_URL=$(printenv keycloak-external-url)
KEYCLOAK_CLIENT="mosip-deployment-client"
KEYCLOAK_CLIENT_SECRET="$mosip_deployment_client_secret"
echo "KEYCLOAK_CLIENT = $KEYCLOAK_CLIENT"
#echo "KEYCLOAK_CLIENT_SECRET = $KEYCLOAK_CLIENT_SECRET"
KEYCLOAK_ADMIN_USERNAME="$( printenv KEYCLOAK_ADMIN_USER)"
KEYCLOAK_ADMIN_PASSWORD=$( printenv admin-password )
echo " KEYCLOAK ADMIN USER : $KEYCLOAK_ADMIN_USER"
#echo " KEYCLOAK ADMIN PASSWORD : $KEYCLOAK_ADMIN_PASSWORD"
URL="https://$(printenv mosip-api-internal-host)"
EXTERNAL_URL="https://$(printenv mosip-api-host)"

echo "URL : $URL and $EXTERNAL_URL"

if [ "$ENABLE_INSECURE" = "true" ]; then
  export HOST=$(printenv mosip-api-internal-host)
  if [ -z $HOST ]; then
    echo "Env variable mosip-api-internal-host not provided; EXITING;";
    exit 1;
  fi
  openssl s_client -servername "$HOST" -connect "$HOST":443  > "$MYDIR/$HOST.cer" 2>/dev/null & sleep 2 ;
  sed -i -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' "$MYDIR/$HOST.cer";
  cat "$MYDIR/$HOST.cer";

  export ADD_SSL_CURL="--cacert $MYDIR/$HOST.cer"
  export ADD_SSL_NEWMAN="--ssl-extra-ca-certs $MYDIR/$HOST.cer"
fi

if [ "$MODULE" = "ida" ]; then
  upload_ida_root_cert
  upload_ida_cert
  upload_ida_partner_cert
  upload_ida_cred_cert
elif [ "$MODULE" = "print" ]; then
  upload_print_cert
elif [ "$MODULE" = "resident" ]; then
  upload_resident_cert
elif [ "$MODULE" = "abis" ]; then
  upload_abis_cert
elif [ "$MODULE" = "mobileid" ]; then
  upload_mpartner_default_mobile_cert
elif [ "$MODULE" = "digitalcard" ]; then
  upload_mpartner_default_digitalcard_cert
elif [ "$MODULE" = "esignet" ]; then
  APPLICATION_ID=partner
  MODULE_CLIENTID=mosip-pms-client
  MODULE_SECRETKEY=$mosip_pms_client_secret
  POLICY_NAME=mpolicy-default-esignet
  POLICY_GROUP_NAME=mpolicygroup-default-esignet
  PARTNER_KC_USERNAME=mpartner-default-esignet
  PARTNER_ORGANIZATION_NAME=IITB
  PARTNER_TYPE=Misp_Partner
  onboard_esignet_partner
elif [ "$MODULE" = "demo-oidc" ]; then
  APPLICATION_ID=partner
  MODULE_CLIENTID=mosip-pms-client
  MODULE_SECRETKEY=$mosip_pms_client_secret
  POLICY_NAME=mpolicy-default-demo-oidc
  POLICY_GROUP_NAME=mpolicygroup-default-demo-oidc
  export PARTNER_KC_USERNAME=mpartner-default-demo-oidc
  PARTNER_ORGANIZATION_NAME=IITB
  PARTNER_TYPE=Auth_Partner
  OIDC_CLIENT_NAME='Health service OIDC Client'
  LOGO_URI=https://healthservices.$( printenv installation-domain)/logo.png
  REDIRECT_URI=https://healthservices.$( printenv installation-domain)/userprofile
  root_cert_path="$MYDIR/certs/$PARTNER_KC_USERNAME/RootCA.pem"
  client_cert_path="$MYDIR/certs/$PARTNER_KC_USERNAME/Client.pem"
  onboard_relying_party_with_demo_oidc_client
elif [ "$MODULE" = "resident-oidc" ]; then
  APPLICATION_ID=partner
  MODULE_CLIENTID=mosip-pms-client
  MODULE_SECRETKEY=$mosip_pms_client_secret
  POLICY_NAME=mpolicy-default-resident-oidc
  POLICY_GROUP_NAME=mpolicygroup-default-resident-oidc
  PARTNER_KC_USERNAME=mpartner-default-resident-oidc
  PARTNER_ORGANIZATION_NAME=IITB
  PARTNER_TYPE=Auth_Partner
  OIDC_CLIENT_NAME=Resident-Portal
  LOGO_URI="https://$( printenv mosip-resident-host )/assets/MOSIP%20Vertical%20Black.png"
  REDIRECT_URI="https://$( printenv mosip-api-internal-host )/resident/v1/login-redirect/**"
  onboard_resident_oidc_client
  elif [ "$MODULE" = "mimoto-keybinding" ]; then
  APPLICATION_ID=partner
  MODULE_CLIENTID=mosip-pms-client
  MODULE_SECRETKEY=$mosip_pms_client_secret
  POLICY_NAME=mpolicy-default-mimotokeybinding
  POLICY_GROUP_NAME=mpolicygroup-default-mimotokeybinding
  export PARTNER_KC_USERNAME=mpartner-default-mimotokeybinding
  PARTNER_KC_USERPASSWORD=mimotokeybinding-kc-mockuserpassword
  PARTNER_ORGANIZATION_NAME=IITB
  PARTNER_TYPE=Auth_Partner
  root_cert_path="$MYDIR/certs/$PARTNER_KC_USERNAME/RootCA.pem"
  client_cert_path="$MYDIR/certs/$PARTNER_KC_USERNAME/Client.pem"
  onboard_mimoto_keybinding_partner
  elif [ "$MODULE" = "mimoto-oidc" ]; then
  APPLICATION_ID=partner
  MODULE_CLIENTID=mosip-pms-client
  MODULE_SECRETKEY=$mosip_pms_client_secret
  POLICY_NAME=mpolicy-default-mimotooidc
  POLICY_GROUP_NAME=mpolicygroup-default-mimotooidc
  export PARTNER_KC_USERNAME=mpartner-default-mimotooidc
  PARTNER_KC_USERPASSWORD=mimotooidc-kc-mockuserpassword
  PARTNER_ORGANIZATION_NAME=IITB
  PARTNER_TYPE=Auth_Partner
  root_cert_path="$MYDIR/certs/$PARTNER_KC_USERNAME/RootCA.pem"
  client_cert_path="$MYDIR/certs/$PARTNER_KC_USERNAME/Client.pem"
  onboard_mimoto_oidc_partner
fi
