// Copyright (c) 2021, Oracle Corporation and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

param _artifactsLocation string = deployment().properties.templateLink.uri
@secure()
param _artifactsLocationSasToken string = ''

param aksClusterRGName string = ''
param aksClusterName string = ''
param acrName string = ''
param appPackageUrls array = []
param appPackageFromStorageBlob object = {
  storageAccountName: 'stg-contoso'
  containerName: 'container-contoso'
}
param azCliVersion string = ''
param identity object = {}
param location string

@secure()
param ocrSSOPSW string
param ocrSSOUser string

param utcValue string = utcNow()
param wlsDomainName string = 'domain1'
param wlsDomainUID string = 'sample-domain1'
param wlsImageTag string = '12.2.1.4'
param userProvidedImagePath string = 'null'
param useOracleImage bool = true

var const_arguments = '${ocrSSOUser} ${ocrSSOPSW} ${aksClusterRGName} ${aksClusterName} ${wlsImageTag} ${acrName} ${wlsDomainName} ${wlsDomainUID} ${resourceGroup().name} ${string(appPackageUrls)} ${const_scriptLocation} ${appPackageFromStorageBlob.storageAccountName} ${appPackageFromStorageBlob.containerName} ${userProvidedImagePath} ${useOracleImage} '
var const_buildDockerImageScript='createVMAndBuildImage.sh'
var const_commonScript = 'common.sh'
var const_invokeScript = 'invokeUpdateApplications.sh'
var const_scriptLocation = uri(_artifactsLocation, 'scripts/')
var const_updateAppScript= 'updateApplications.sh'
var const_utilityScript= 'utility.sh'

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'ds-wls-update-applications'
  location: location
  kind: 'AzureCLI'
  identity: identity
  properties: {
    azCliVersion: azCliVersion
    arguments: const_arguments
    primaryScriptUri: uri(const_scriptLocation, '${const_invokeScript}${_artifactsLocationSasToken}')
    supportingScriptUris: [
      uri(const_scriptLocation, '${const_updateAppScript}${_artifactsLocationSasToken}')
      uri(const_scriptLocation, '${const_commonScript}${_artifactsLocationSasToken}')
      uri(const_scriptLocation, '${const_utilityScript}${_artifactsLocationSasToken}')
      uri(const_scriptLocation, '${const_buildDockerImageScript}${_artifactsLocationSasToken}')
    ]
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
    forceUpdateTag: utcValue
  }
}

output image string = reference('ds-wls-update-applications').outputs.image
