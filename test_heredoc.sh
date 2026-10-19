cat << 'MOCK_CURL'
if [[ "\$MOCK_CURL_FAIL" == "1" ]]; then
    echo "\$MOCK_CURL_RESPONSE"
fi
MOCK_CURL
