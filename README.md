# Kong plugin to add user to wsse header


# About

This Kong 🦍 plugin is developed to add to an incoming SOAP call a wsse UserToken header
entry. It is not meant to go into production, but show the concept on how this approach could be achieved.

## Configuration parameters
There are 2 required parameters to configure the plugin

|FORM PARAMETER|REQUIRED|DEFAULT|DESCRIPTION|
|:----|:------|:------|:------|
|config.username|true||Username for the User Token |
|config.password|true||Password for the User Token |

## Additional libraries needed
none

# Example

if one sends 
``` xml
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    <soap:Body>
        <FindAemter xmlns="http://service.aemterfinden.ch/V1/01/" xmlns:ns2="http://schema.aemterfinden.ch/V1/01"
                    xmlns:ns3="http://schemas.microsoft.com/2003/10/Serialization/Arrays"
                    xmlns:ns4="http://schemas.microsoft.com/2003/10/Serialization/">
            <amtSearchRequest/>
       </FindAemter>
    </soap:Body>
</soap:Envelope>
```
the plugin will add a UserToken Header 

``` xml
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
	<soap:Header>
        <wsse:Security soap:mustUnderstand="1"
                       xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"
                       xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">
            <wsse:UsernameToken>
                <wsse:Username>someuser</wsse:Username>
                <wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">
                     **********
                </wsse:Password>
                <wsse:Nonce
                        EncodingType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary">
                        somenonce
                </wsse:Nonce>
                <wsu:Created>2023-07-14T07:44:51Z</wsu:Created>
            </wsse:UsernameToken>
        </wsse:Security>
    </soap:Header>
    <soap:Body>
        <FindAemter xmlns="http://service.aemterfinden.ch/V1/01/" xmlns:ns2="http://schema.aemterfinden.ch/V1/01"
                    xmlns:ns3="http://schemas.microsoft.com/2003/10/Serialization/Arrays"
                    xmlns:ns4="http://schemas.microsoft.com/2003/10/Serialization/">
            <amtSearchRequest/>
       </FindAemter>
    </soap:Body>
</soap:Envelope>
```
