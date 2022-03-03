/**********************************************************************************************************************************
* Copyright © 2021 Creditas
* ================================================================================================================================
* Purpose: Class Refactor for IntegrationAsset
* ================================================================================================================================
* History
* -------
* VERSION   AUTHOR                  DATE            DETAIL      Description
*  1.0      Gabriel Vidal           03/03/2022      Created     Class Refactor for IntegrationAsset
**********************************************************************************************************************************/
@RestResource(urlMapping='/IntegrationAsset/*')
global without sharing class IntegrationAssetController 
{
    @HttpPut
    global static void putMethod()
    {
        IntegrationAssetService service = new IntegrationAssetService();
        service.upsertAsset();         
    }
}