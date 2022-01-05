<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2"
                exclude-result-prefixes="#all"
                expand-text="yes"
                version="3.0">

  <xsl:output method="xml" indent="yes"/>
  <!-- Changelog
  Last updated: 16.11.2021 13:00
  Last updated by: Andreas Viljugrein
  Created by: Marius Ø
  
  Changes:
  Date       Change
  13.10.21   Added KID (PaymentID), added change header, changed invoice and creditnote logix. Added number formattign for decimal
  14.10.21   Added ProjectNumber field in AdditionalDocumentReference
  25.10.21   Added Country code mapping. New template for mapping and changed variable for getting schemeid. Remove Whitespace from orgnumber and paymentID.
  26.10.21   Removed IF logiq on taxamount. Added new template for fetching numbers and removing minus
  04.11.21   Corrected ordernumber and linefield names. Creditnote check adapted. IBAN and Bankgiro added. 
  08.11.21	 Added date check. Invoicedate and duedate must be 10 sign (yyyy-mm-dd), if not we don't show the tag.
  11.11.21   Added header rounding amount and allowance charge in total amounts
  17.11.21   Added EmbeddedDocumentBinaryObject. mimetype and filename
  -->
  <xsl:variable name="documentNote">
    <xsl:text>Levert via ECIT Digital</xsl:text>
  </xsl:variable>
  <xsl:variable name="DebugIncludeOriginal">0</xsl:variable>
  <!--
  *
  *  If you want to remap data to a new type,
  *  please adjust the following variables:
  *
  -->
  <xsl:template name="documentTypeMapper">
    <xsl:param name="sourceDocumentType" />
    <xsl:choose>
      <xsl:when test="$sourceDocumentType = 'INVOICE'">380</xsl:when>
      <xsl:when test="$sourceDocumentType = 'CREDIT-NOTE'">381</xsl:when>
      <xsl:when test="$sourceDocumentType = 'CREDITNOTE'">381</xsl:when>
      <xsl:when test="$sourceDocumentType = 'creditnote'">381</xsl:when>
      <xsl:otherwise>380</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--                     FIELD NAMES                        -->
  <!-- Header fields -->
  <xsl:variable name="fieldSchema_invoiceNumber">InvoiceNumber</xsl:variable>
  <xsl:variable name="fieldSchema_invoiceDate">InvoiceCreatedDate</xsl:variable>
  <xsl:variable name="fieldSchema_dueDate">InvoiceDueDate</xsl:variable>
  <xsl:variable name="fieldSchema_docType">doc_type</xsl:variable>
  <xsl:variable name="fieldSchema_orderRef">InvoiceOrderNumber</xsl:variable>
  <xsl:variable name="fieldSchema_yourRef">YourReference</xsl:variable>
  <xsl:variable name="fieldSchema_currency">InvoiceCurrency</xsl:variable>
  <xsl:variable name="fieldSchema_ProjectNumber">ProjectNumber</xsl:variable>
  

  <!-- Supplier -->
  <xsl:variable name="fieldSchema_CustomerName">name</xsl:variable>
  <xsl:variable name="fieldSchema_CustomerRegistrationName">SupplierName</xsl:variable>
  <xsl:variable name="fieldSchema_CustomerEndpoint">org_number</xsl:variable>
  <xsl:variable name="fieldSchema_CustomerPartyIdentification">org_number</xsl:variable>
  <xsl:variable name="fieldSchema_CustomerOrgno">org_number</xsl:variable>
  <xsl:variable name="fieldSchema_CustomerTaxNumber">XXNOTHINGXX</xsl:variable>
  <xsl:variable name="fieldSchema_CustomerStreetname">XXNOTHINGXX</xsl:variable>
  <xsl:variable name="fieldSchema_CustomerAdditionalStreetName">XXNOTHINGXX</xsl:variable>
  <xsl:variable name="fieldSchema_CustomerCityName">XXNOTHINGXX</xsl:variable>
  <xsl:variable name="fieldSchema_CustomerPostalZone">XXNOTHINGXX</xsl:variable>
  <xsl:variable name="fieldSchema_CustomerCountrySubentity">XXNOTHINGXX</xsl:variable>
  <xsl:variable name="fieldSchema_CustomerCountryIdentificationCode">XXNOTHINGXX</xsl:variable>
  
  <xsl:variable name="fieldSchema_SupplierOrgnoScheme">SupplierCountry</xsl:variable>
  <xsl:variable name="fieldSchema_SupplierEndpointSchemeID">SupplierCountry</xsl:variable>
  <xsl:variable name="fieldSchema_SupplierPartyIdentificationSchemeID">SupplierCountry</xsl:variable>
 


  <!-- Hardcoded -->
   
    <xsl:variable name="fieldSchema_CustomerPartyIdentificationSchemeID"><xsl:text>0007</xsl:text></xsl:variable>
    <xsl:variable name="fieldSchema_CustomerOrgnoScheme"><xsl:text>0007</xsl:text></xsl:variable>
    <xsl:variable name="fieldSchema_CustomerTaxScheme"><xsl:text>VAT</xsl:text></xsl:variable>
  <xsl:variable name="fieldSchema_CustomerEndpointSchemeID"><xsl:text>0007</xsl:text></xsl:variable>
  <!-- Customer -->
  <xsl:variable name="fieldSchema_SupplierName">SupplierName</xsl:variable>
  <xsl:variable name="fieldSchema_SupplierRegistrationName">SupplierName</xsl:variable>
  <xsl:variable name="fieldSchema_SupplierEndpoint">supp_vat</xsl:variable>
  <xsl:variable name="fieldSchema_SupplierPartyIdentification">supp_vat</xsl:variable>
  <xsl:variable name="fieldSchema_SupplierOrgno">SupplierCompanyID</xsl:variable>
  <xsl:variable name="fieldSchema_SupplierTaxNumber">XXNOTHINGXX</xsl:variable>
  <xsl:variable name="fieldSchema_SupplierStreetname">XXNOTHINGXX</xsl:variable>
  <xsl:variable name="fieldSchema_SupplierAdditionalStreetName">XXNOTHINGXX</xsl:variable>
  <xsl:variable name="fieldSchema_SupplierCityName">XXNOTHINGXX</xsl:variable>
  <xsl:variable name="fieldSchema_SupplierPostalZone">XXNOTHINGXX</xsl:variable>
  <xsl:variable name="fieldSchema_SupplierCountrySubentity">XXNOTHINGXX</xsl:variable>
  <xsl:variable name="fieldSchema_SupplierCountryIdentificationCode">XXNOTHINGXX</xsl:variable>
   
  
  
  <!-- Hardcoded-->
   

    <xsl:variable name="fieldSchema_SupplierTaxScheme"><xsl:text>VAT</xsl:text></xsl:variable>

  <!-- Totals -->
  <xsl:variable name="fieldSchema_LineExtensionAmount">Netamount</xsl:variable>
  <xsl:variable name="fieldSchema_TaxExclusiveAmount">Netamount</xsl:variable>
  <xsl:variable name="fieldSchema_TaxInclusiveAmount">InvoiceTotalAmountInclTax</xsl:variable>
  <xsl:variable name="fieldSchema_AllowanceTotalAmount">InvoiceAllowanceCharge</xsl:variable>
  <xsl:variable name="fieldSchema_ChargeTotalAmount"></xsl:variable>
  <xsl:variable name="fieldSchema_PrepaidAmount"></xsl:variable>
  <xsl:variable name="fieldSchema_PayableRoundingAmount">InvoiceRoundingAmountHeader</xsl:variable>
  <xsl:variable name="fieldSchema_PayableAmount">InvoiceTotalAmountInclTax</xsl:variable>
  <xsl:variable name="fieldSchema_TaxAmount">TaxAmount</xsl:variable>

  <!--  Bank info-->
  <xsl:variable name="fieldSchema_PayeeFinancialAccountID">SupplierBankAccount</xsl:variable>
  <xsl:variable name="fieldSchema_PayeeFinancialAccountIBAN">SupplierIBAN</xsl:variable>
  <xsl:variable name="fieldSchema_PaymentID">InvoicePaymentID</xsl:variable>
  <xsl:variable name="fieldSchema_PaymentMeansCode"><xsl:text>31</xsl:text></xsl:variable>

  <!-- Line info -->
  <xsl:variable name="fieldSchema_lineDescription">InvoiceDescriptionLine</xsl:variable>
  <xsl:variable name="fieldSchema_lineQuantity">InvoiceQuantityLine</xsl:variable>
  <xsl:variable name="fieldSchema_ItemPriceBaseQuantity"><xsl:text>1</xsl:text></xsl:variable>
    <!-- If no price, uses netamount / quanity -->
  <xsl:variable name="fieldSchema_linePrice">InvoiceUnitPriceLine</xsl:variable>
  <xsl:variable name="fieldSchema_lineTaxAmount">tax_amount_line</xsl:variable>
  <xsl:variable name="fieldSchema_lineNetAmount">InvoiceNetAmountLine</xsl:variable>
  <xsl:variable name="fieldSchema_productNo">ProductIdLine</xsl:variable>
  <xsl:variable name="fieldSchema_taxCodeScheme">XXNOTHINGXX</xsl:variable>
  <xsl:variable name="fieldSchema_taxPercent">XXNOTHINGXX</xsl:variable>

  <!-- Fetching templates -->

  <xsl:template name="fetchFromCustomerFinalvalueByFieldschema">
    <xsl:param name="ffheadfbf_field_schema" />
    <xsl:value-of select="/ocr_data/customer/*[local-name() = $ffheadfbf_field_schema]" />
  </xsl:template>

  <xsl:template name="fetchFromHeaderFinalvalueByFieldschema">
    <xsl:param name="ffheadfbf_field_schema" />
    <xsl:value-of select="/ocr_data/header/*[local-name() = $ffheadfbf_field_schema]" />
  </xsl:template>
  
  <!-- Seperate method for fetching amount fields and removing any leading minus-->
  <xsl:template name="fetchFromHeaderAmountFinalvalueByFieldschema">
    <xsl:param name="ffheadfbf_field_schema" />
    <xsl:value-of select="translate(/ocr_data/header/*[local-name() = $ffheadfbf_field_schema],'-','')" />
  </xsl:template>
  
  
  <!-- Seperate template for countries to choose correct code-->
  <xsl:template name="fetchFromHeaderCountryID">
    <xsl:param name="ffheadfbf_field_schema" />
    
 <!-- Hente ut land fra filen og legge det i en variabel som vi bruker senere-->   
    <xsl:variable name="templand">  
      <xsl:value-of select="/ocr_data/header/*[local-name() = $ffheadfbf_field_schema]" />
    </xsl:variable>
 
      <!-- Teste om verdien fra filen matcher landkode og sette tallverdi -->
    <xsl:choose>
      <xsl:when test="$templand = 'FR'">0002</xsl:when>	
      <xsl:when test="$templand = 'SE'">0007</xsl:when>	
      <xsl:when test="$templand = 'FR'">0009</xsl:when>	
      <xsl:when test="$templand = 'FI'">0037</xsl:when>	
      <xsl:when test="$templand = 'DU'">0060</xsl:when>	
      <xsl:when test="$templand = 'GL'">0088</xsl:when>	
      <xsl:when test="$templand = 'IT'">0097</xsl:when>	
      <xsl:when test="$templand = 'NL'">0106</xsl:when>	
      <xsl:when test="$templand = 'EU'">0130</xsl:when>	
      <xsl:when test="$templand = 'IT'">0135</xsl:when>	
      <xsl:when test="$templand = 'IT'">0142</xsl:when>	
      <xsl:when test="$templand = 'AU'">0151</xsl:when>	
      <xsl:when test="$templand = 'CH'">0183</xsl:when>	
      <xsl:when test="$templand = 'DK'">0184</xsl:when>	
      <xsl:when test="$templand = 'NL'">0190</xsl:when>	
      <xsl:when test="$templand = 'EE'">0191</xsl:when>	
      <xsl:when test="$templand = 'NO'">0192</xsl:when>	
      <xsl:when test="$templand = 'UB'">0193</xsl:when>	
      <xsl:when test="$templand = 'SG'">0195</xsl:when>	
      <xsl:when test="$templand = 'IS'">0196</xsl:when>	
      <xsl:when test="$templand = 'DK'">0198</xsl:when>	
      <xsl:when test="$templand = 'LE'">0199</xsl:when>	
      <xsl:when test="$templand = 'LT'">0200</xsl:when>	
      <xsl:when test="$templand = 'IT'">0201</xsl:when>	
      <xsl:when test="$templand = 'DE'">0204</xsl:when>	
      <xsl:when test="$templand = 'BE'">0208</xsl:when>	
      
      
      <xsl:otherwise>0007</xsl:otherwise>
    </xsl:choose>
    
  
  </xsl:template>
  
  

  <xsl:template name="fetchFromLineFinalvalueByFieldschema">
    <!-- Is defined on template far down in the document -->
  </xsl:template>
  
  
  
  
  


  <!--               FETCHERS                  -->

  <!-- Header -->
  <xsl:variable name="invoiceNumber">
    <xsl:call-template name="fetchFromHeaderFinalvalueByFieldschema">
      <xsl:with-param name="ffheadfbf_field_schema" select="$fieldSchema_invoiceNumber" />
    </xsl:call-template>
  </xsl:variable>
  
  <xsl:variable name="originalInvoiceDate">
    <xsl:call-template name="fetchFromHeaderFinalvalueByFieldschema">
      <xsl:with-param name="ffheadfbf_field_schema" select="$fieldSchema_invoiceDate" />
    </xsl:call-template>
  </xsl:variable>
  
  <xsl:variable name="originalDueDate">
    <xsl:call-template name="fetchFromHeaderFinalvalueByFieldschema">
      <xsl:with-param name="ffheadfbf_field_schema" select="$fieldSchema_dueDate" />
    </xsl:call-template>
  </xsl:variable>
  
  <xsl:variable name="yourRef">
    <xsl:call-template name="fetchFromHeaderFinalvalueByFieldschema">
      <xsl:with-param name="ffheadfbf_field_schema" select="$fieldSchema_yourRef" />
    </xsl:call-template>
  </xsl:variable>
  
  <xsl:variable name="orderRef">
    <xsl:call-template name="fetchFromHeaderFinalvalueByFieldschema">
      <xsl:with-param name="ffheadfbf_field_schema" select="$fieldSchema_orderRef" />
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="ProjectNumber">
    <xsl:call-template name="fetchFromHeaderFinalvalueByFieldschema">
      <xsl:with-param name="ffheadfbf_field_schema" select="$fieldSchema_ProjectNumber" />
    </xsl:call-template>
  </xsl:variable>
  
  <xsl:variable 
    name="invoiceDate">
    <xsl:call-template name="dateConvertddDOTmmDOTyyyy">
      <xsl:with-param name="originalDate" select="$originalInvoiceDate" />
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable 
    name="dueDate">
    <xsl:call-template name="dateConvertddDOTmmDOTyyyy">
      <xsl:with-param name="originalDate" select="$originalDueDate" />
    </xsl:call-template>
  </xsl:variable>
  
  <xsl:variable 
    name="sourceDocCode">
    <xsl:call-template name="fetchFromHeaderFinalvalueByFieldschema">
      <xsl:with-param name="ffheadfbf_field_schema" select="$fieldSchema_docType" />
    </xsl:call-template>
  </xsl:variable>
  
  <xsl:variable 
    name="documentType">
    <xsl:call-template name="documentTypeMapper">
      <xsl:with-param name="sourceDocumentType" select="$sourceDocCode" />
    </xsl:call-template>
  </xsl:variable>
  
  <xsl:variable 
    name="globalCurrencyCode">
    <xsl:call-template name="fetchFromHeaderFinalvalueByFieldschema">
      <xsl:with-param name="ffheadfbf_field_schema" select="$fieldSchema_currency" />
    </xsl:call-template>
  </xsl:variable>

  <!-- Customer -->
  <xsl:variable name="CustomerName">
    <xsl:call-template name="fetchFromCustomerFinalvalueByFieldschema">
      <xsl:with-param name="ffheadfbf_field_schema" select="$fieldSchema_CustomerName" />
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="CustomerRegistrationName">
    <xsl:call-template name="fetchFromCustomerFinalvalueByFieldschema">
      <xsl:with-param name="ffheadfbf_field_schema" select="$fieldSchema_CustomerRegistrationName" />
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="CustomerEndpoint">
    <xsl:call-template name="fetchFromCustomerFinalvalueByFieldschema">
      <xsl:with-param name="ffheadfbf_field_schema" select="$fieldSchema_CustomerEndpoint" />
    </xsl:call-template>
  </xsl:variable>
  
  <xsl:variable name="CustomerEndpointSchemeID">
    <xsl:value-of select="$fieldSchema_CustomerEndpointSchemeID"/>
  
  </xsl:variable>
  
  <xsl:variable name="CustomerPartyIdentification">
    <xsl:call-template name="fetchFromCustomerFinalvalueByFieldschema">
      <xsl:with-param name="ffheadfbf_field_schema" select="$fieldSchema_CustomerPartyIdentification" />
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="CustomerPartyIdentificationSchemeID">
    <xsl:value-of select="$fieldSchema_CustomerPartyIdentificationSchemeID"/>
  </xsl:variable>
  <xsl:variable name="CustomerOrgno">
    <xsl:call-template name="fetchFromCustomerFinalvalueByFieldschema">
      <xsl:with-param name="ffheadfbf_field_schema" select="$fieldSchema_CustomerOrgno" />
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="CustomerOrgnoScheme">
    <xsl:value-of select="$fieldSchema_CustomerOrgnoScheme"/>
  </xsl:variable>
  <xsl:variable name="CustomerTaxNumber">
    <xsl:call-template name="fetchFromCustomerFinalvalueByFieldschema">
      <xsl:with-param name="ffheadfbf_field_schema" select="$fieldSchema_CustomerTaxNumber" />
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="CustomerTaxScheme">
    <xsl:value-of select="$fieldSchema_CustomerTaxScheme"/>
  </xsl:variable>
  <xsl:variable name="CustomerStreetname">
    <xsl:call-template name="fetchFromCustomerFinalvalueByFieldschema">
      <xsl:with-param name="ffheadfbf_field_schema" select="$fieldSchema_CustomerStreetname" />
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="CustomerAdditionalStreetName">
    <xsl:call-template name="fetchFromCustomerFinalvalueByFieldschema">
      <xsl:with-param name="ffheadfbf_field_schema" select="$fieldSchema_CustomerAdditionalStreetName" />
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="CustomerCityName">
    <xsl:call-template name="fetchFromCustomerFinalvalueByFieldschema">
      <xsl:with-param name="ffheadfbf_field_schema" select="$fieldSchema_CustomerCityName" />
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="CustomerPostalZone">
    <xsl:call-template name="fetchFromCustomerFinalvalueByFieldschema">
      <xsl:with-param name="ffheadfbf_field_schema" select="$fieldSchema_CustomerPostalZone" />
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="CustomerCountrySubentity">
    <xsl:call-template name="fetchFromCustomerFinalvalueByFieldschema">
      <xsl:with-param name="ffheadfbf_field_schema" select="$fieldSchema_CustomerCountrySubentity" />
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="CustomerCountryIdentificationCode">
    <xsl:call-template name="fetchFromCustomerFinalvalueByFieldschema">
      <xsl:with-param name="ffheadfbf_field_schema" select="$fieldSchema_CustomerCountryIdentificationCode" />
    </xsl:call-template>
  </xsl:variable>

  <!-- Supplier -->
  <xsl:variable name="SupplierName">
    <xsl:call-template name="fetchFromHeaderFinalvalueByFieldschema">
      <xsl:with-param name="ffheadfbf_field_schema" select="$fieldSchema_SupplierName" />
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="SupplierEndpoint">
    <xsl:call-template name="fetchFromHeaderFinalvalueByFieldschema">
      <xsl:with-param name="ffheadfbf_field_schema" select="$fieldSchema_SupplierEndpoint" />
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="SupplierEndpointSchemeID">
    <xsl:value-of select="$fieldSchema_SupplierEndpointSchemeID"/>
  </xsl:variable>
  <xsl:variable name="SupplierPartyIdentification">
    <xsl:call-template name="fetchFromHeaderFinalvalueByFieldschema">
      <xsl:with-param name="ffheadfbf_field_schema" select="$fieldSchema_SupplierPartyIdentification" />
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="SupplierPartyIdentificationSchemeID">
    <xsl:value-of select="$fieldSchema_SupplierPartyIdentificationSchemeID"/>
  </xsl:variable>
  <xsl:variable name="SupplierOrgno">
    <xsl:call-template name="fetchFromHeaderFinalvalueByFieldschema">
      <xsl:with-param name="ffheadfbf_field_schema" select="$fieldSchema_SupplierOrgno" />
    </xsl:call-template>
  </xsl:variable>
  
  <!-- We call a seperate template for finding country-->
  <xsl:variable name="SupplierOrgnoScheme">
    <xsl:call-template name="fetchFromHeaderCountryID">
      <xsl:with-param name="ffheadfbf_field_schema" select="$fieldSchema_SupplierOrgnoScheme" />
    </xsl:call-template>

  </xsl:variable>
  
  
  <xsl:variable name="SupplierTaxNumber">
    <xsl:call-template name="fetchFromHeaderFinalvalueByFieldschema">
      <xsl:with-param name="ffheadfbf_field_schema" select="$fieldSchema_SupplierTaxNumber" />
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="SupplierTaxScheme">
    <xsl:value-of select="$fieldSchema_SupplierTaxScheme"/>
  </xsl:variable>
  <xsl:variable name="SupplierStreetname">
    <xsl:call-template name="fetchFromHeaderFinalvalueByFieldschema">
      <xsl:with-param name="ffheadfbf_field_schema" select="$fieldSchema_SupplierStreetname" />
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="SupplierAdditionalStreetName">
    <xsl:call-template name="fetchFromHeaderFinalvalueByFieldschema">
      <xsl:with-param name="ffheadfbf_field_schema" select="$fieldSchema_SupplierAdditionalStreetName" />
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="SupplierCityName">
    <xsl:call-template name="fetchFromHeaderFinalvalueByFieldschema">
      <xsl:with-param name="ffheadfbf_field_schema" select="$fieldSchema_SupplierCityName" />
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="SupplierPostalZone">
    <xsl:call-template name="fetchFromHeaderFinalvalueByFieldschema">
      <xsl:with-param name="ffheadfbf_field_schema" select="$fieldSchema_SupplierPostalZone" />
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="SupplierCountrySubentity">
    <xsl:call-template name="fetchFromHeaderFinalvalueByFieldschema">
      <xsl:with-param name="ffheadfbf_field_schema" select="$fieldSchema_SupplierCountrySubentity" />
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="SupplierCountryIdentificationCode">
    <xsl:call-template name="fetchFromHeaderFinalvalueByFieldschema">
      <xsl:with-param name="ffheadfbf_field_schema" select="$fieldSchema_SupplierCountryIdentificationCode" />
    </xsl:call-template>
  </xsl:variable>

  <!-- Totals -->
  <xsl:variable name="LineExtensionAmount">
    <xsl:call-template name="fetchFromHeaderAmountFinalvalueByFieldschema">
      <xsl:with-param name="ffheadfbf_field_schema" select="$fieldSchema_LineExtensionAmount" />
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="TaxExclusiveAmount">
    <xsl:call-template name="fetchFromHeaderAmountFinalvalueByFieldschema">
      <xsl:with-param name="ffheadfbf_field_schema" select="$fieldSchema_TaxExclusiveAmount" />
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="TaxInclusiveAmount">
    <xsl:call-template name="fetchFromHeaderAmountFinalvalueByFieldschema">
      <xsl:with-param name="ffheadfbf_field_schema" select="$fieldSchema_TaxInclusiveAmount" />
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="AllowanceTotalAmount">
    <xsl:call-template name="fetchFromHeaderAmountFinalvalueByFieldschema">
      <xsl:with-param name="ffheadfbf_field_schema" select="$fieldSchema_AllowanceTotalAmount" />
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="ChargeTotalAmount">
    <xsl:call-template name="fetchFromHeaderAmountFinalvalueByFieldschema">
      <xsl:with-param name="ffheadfbf_field_schema" select="$fieldSchema_ChargeTotalAmount" />
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="PrepaidAmount">
    <xsl:call-template name="fetchFromHeaderAmountFinalvalueByFieldschema">
      <xsl:with-param name="ffheadfbf_field_schema" select="$fieldSchema_PrepaidAmount" />
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="PayableRoundingAmount">
    <xsl:call-template name="fetchFromHeaderAmountFinalvalueByFieldschema">
      <xsl:with-param name="ffheadfbf_field_schema" select="$fieldSchema_PayableRoundingAmount" />
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="PayableAmount">
    <xsl:call-template name="fetchFromHeaderAmountFinalvalueByFieldschema">
      <xsl:with-param name="ffheadfbf_field_schema" select="$fieldSchema_PayableAmount" />
    </xsl:call-template>
  </xsl:variable>

  <!-- Tax Totals --> 
  <xsl:variable name="TaxAmount">
    <xsl:call-template name="fetchFromHeaderAmountFinalvalueByFieldschema">
      <xsl:with-param name="ffheadfbf_field_schema" select="$fieldSchema_TaxAmount" />
    </xsl:call-template>
  </xsl:variable>

  <!-- PaymnetMeans -->
  <!-- Payment means codes: https://docs.peppol.eu/poacc/billing/3.0/codelist/UNCL4461/ -->
  <!-- 31 - Debit transfer - Payment by debit movement of funds from one account to another. -->

  <xsl:variable name="PaymentMeansCode">
    <xsl:value-of select="$fieldSchema_PaymentMeansCode"/>
  </xsl:variable>
  <xsl:variable name="PaymentID">
    <xsl:call-template name="fetchFromHeaderFinalvalueByFieldschema">
      <xsl:with-param name="ffheadfbf_field_schema" select="$fieldSchema_PaymentID" />
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="PayeeFinancialAccountID">
    <xsl:call-template name="fetchFromHeaderFinalvalueByFieldschema">
      <xsl:with-param name="ffheadfbf_field_schema" select="$fieldSchema_PayeeFinancialAccountID" />
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="PayeeFinancialAccountIBAN">
    <xsl:call-template name="fetchFromHeaderFinalvalueByFieldschema">
      <xsl:with-param name="ffheadfbf_field_schema" select="$fieldSchema_PayeeFinancialAccountIBAN" />
    </xsl:call-template>
  </xsl:variable>
  
  
  <xsl:variable name="FinancialInstitutionBranchID">SE:BANKGIRO</xsl:variable>

<!--
*
*    Under here is the templates that generate the EHF file
*
-->

  <xsl:template match="/">
    <Invoice xmlns="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2"
      xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"
      xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2">

      <cbc:CustomizationID>urn:cen.eu:en16931:2017#compliant#urn:fdc:peppol.eu:2017:poacc:billing:3.0</cbc:CustomizationID>

      <cbc:ProfileID>urn:fdc:peppol.eu:2017:poacc:billing:01:1.0</cbc:ProfileID>
      <!-- <cbc:ID>TOSL108</cbc:ID> -->

      <xsl:if test="$invoiceNumber">
        <cbc:ID>
          <xsl:value-of select="$invoiceNumber"/>
        </cbc:ID>
      </xsl:if>

      <xsl:if test="$invoiceDate and string-length($invoiceDate) = 10">
        <cbc:IssueDate>
          <xsl:value-of select="$invoiceDate"/>
        </cbc:IssueDate>
      </xsl:if>
    
      <xsl:if test="$dueDate and string-length($dueDate) = 10">
      <cbc:DueDate>
          <xsl:value-of select="$dueDate"/> 
      </cbc:DueDate>
      
      </xsl:if>
     

      <cbc:InvoiceTypeCode>
        <xsl:value-of select="$documentType"/>
      </cbc:InvoiceTypeCode>
      
      <cbc:Note>
        <xsl:value-of select="$documentNote"/>
      </cbc:Note>

      <!-- <cbc:TaxPointDate>2013-06-30</cbc:TaxPointDate> -->
      
      <cbc:DocumentCurrencyCode>
        <xsl:value-of select="$globalCurrencyCode"/>
      </cbc:DocumentCurrencyCode>
      <!-- <cbc:AccountingCost>Project cost code 123</cbc:AccountingCost> -->

      <xsl:if test="$yourRef and string-length($yourRef) > 0">
        <cbc:BuyerReference>
          <xsl:value-of select="$yourRef" />
        </cbc:BuyerReference>
      </xsl:if>

      <!-- <cac:InvoicePeriod>
        <cbc:StartDate>2013-06-01</cbc:StartDate>
        <cbc:EndDate>2013-06-30</cbc:EndDate>
      </cac:InvoicePeriod> -->
    
    <xsl:if test="$orderRef and string-length($orderRef) > 0">
      <cac:OrderReference>
        <cbc:ID>
          <xsl:value-of select="$orderRef" />
        </cbc:ID>
      </cac:OrderReference>
    </xsl:if>

      <!-- <cac:ContractDocumentReference>
        <cbc:ID>Contract321</cbc:ID>
      </cac:ContractDocumentReference> -->



      <!-- ****************** Additional Doc Refs ********************* -->
      <!-- If project we add it here-->
      
      <xsl:if test="$ProjectNumber and string-length($ProjectNumber) > 0">
          <cac:ProjectReference>
             <cbc:ID>
               
               <xsl:value-of select="$ProjectNumber" />
             
             </cbc:ID>              
        </cac:ProjectReference>    
       </xsl:if>
       <!--
       <cac:Attachment>
          <cac:ExternalReference>
            <cbc:URI>http://www.suppliersite.eu/sheet001.html</cbc:URI>
          </cac:ExternalReference>
        </cac:Attachment>
        -->
      <!-- <pdf encoded="base64" filename="faktura-4025469.pdf" mimetype="application/pdf"> -->
      <xsl:for-each select="/ocr_data/pdf">
        <cac:AdditionalDocumentReference>
          <!-- <xsl:element name="ID">
            
          </xsl:element> -->
		      <cbc:ID>
            <xsl:text>Attachment </xsl:text>
            <xsl:value-of select="position()"/>
          </cbc:ID>
          <!-- <cbc:ID>Doc2</cbc:ID>
          <cbc:DocumentDescription>EHF specification</cbc:DocumentDescription> -->
          <cac:Attachment>
            <cbc:EmbeddedDocumentBinaryObject>
              <xsl:attribute name="filename">
                <xsl:value-of select="@original_filename" />
              </xsl:attribute>
              <xsl:choose>
                <xsl:when test="@mimecode">
                  <xsl:attribute name="mimeCode" select="@mimecode"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:attribute name="mimeCode">application/pdf</xsl:attribute>
                </xsl:otherwise>
              </xsl:choose>
              <!-- <xsl:value-of select="." /> -->
            </cbc:EmbeddedDocumentBinaryObject>
          </cac:Attachment>
        </cac:AdditionalDocumentReference>
      </xsl:for-each>


      <!-- ****************** Accounting Supplier Party ********************* -->
      <cac:AccountingSupplierParty>
        <xsl:call-template name="AccountingParty">
          <xsl:with-param name="Endpoint" select="$SupplierEndpoint"/>
          <xsl:with-param name="EndpointSchemeID" select="$SupplierEndpointSchemeID"/>
          <xsl:with-param name="OrganisationNumber" select="$SupplierOrgno"/>
          <xsl:with-param name="OrganisationNumberSchemeID" select="$SupplierOrgnoScheme"/>
          <xsl:with-param name="PartyIdentification" select="$SupplierPartyIdentification"/>
          <xsl:with-param name="PartyIdentificationSchemeID" select="$SupplierPartyIdentificationSchemeID"/>
          <xsl:with-param name="PartyName" select="$SupplierName"/>
          <xsl:with-param name="TaxNumber" select="$SupplierTaxNumber"/>
          <xsl:with-param name="TaxScheme" select="$SupplierTaxScheme"/>
          <xsl:with-param name="StreetName" select="$SupplierStreetname"/>
          <xsl:with-param name="AdditionalStreetName" select="$SupplierAdditionalStreetName"/>
          <xsl:with-param name="CityName" select="$SupplierCityName"/>
          <xsl:with-param name="PostalZone" select="$SupplierPostalZone"/>
          <xsl:with-param name="CountrySubentity" select="$SupplierCountrySubentity"/>
          <xsl:with-param name="CountryIdentificationCode" select="$SupplierCountryIdentificationCode"/>
        </xsl:call-template>
      </cac:AccountingSupplierParty>


      <!-- ****************** Accounting Customer Party ********************* -->
      <xsl:if test="/ocr_data/customer">
        <cac:AccountingCustomerParty>
          <xsl:call-template name="AccountingParty">
            <xsl:with-param name="Endpoint" select="$CustomerEndpoint"/>
            <xsl:with-param name="EndpointSchemeID" select="$CustomerEndpointSchemeID"/>
            <xsl:with-param name="OrganisationNumber" select="$CustomerOrgno"/>
            <xsl:with-param name="OrganisationNumberSchemeID" select="$CustomerOrgnoScheme"/>
            <xsl:with-param name="PartyIdentification" select="$CustomerPartyIdentification"/>
            <xsl:with-param name="PartyIdentificationSchemeID" select="$CustomerPartyIdentificationSchemeID"/>
            <xsl:with-param name="PartyName" select="$CustomerName"/>
            <xsl:with-param name="TaxNumber" select="$CustomerTaxNumber"/>
            <xsl:with-param name="TaxScheme" select="$CustomerTaxScheme"/>
            <xsl:with-param name="StreetName" select="$CustomerStreetname"/>
            <xsl:with-param name="AdditionalStreetName" select="$CustomerAdditionalStreetName"/>
            <xsl:with-param name="CityName" select="$CustomerCityName"/>
            <xsl:with-param name="PostalZone" select="$CustomerPostalZone"/>
            <xsl:with-param name="CountrySubentity" select="$CustomerCountrySubentity"/>
            <xsl:with-param name="CountryIdentificationCode" select="$CustomerCountryIdentificationCode"/>
          </xsl:call-template>
        </cac:AccountingCustomerParty>
      </xsl:if>


      <!-- ****************** Payee Party ********************* -->
      <!-- <cac:PayeeParty>
        <cac:PartyIdentification>

          <cbc:ID schemeID="0088">2298740918237</cbc:ID>
        </cac:PartyIdentification>
        <cac:PartyName>
          <cbc:Name>Ebeneser Scrooge AS</cbc:Name>
        </cac:PartyName>
        <cac:PartyLegalEntity>

          <cbc:CompanyID schemeID="0192">999999999</cbc:CompanyID>
        </cac:PartyLegalEntity>
      </cac:PayeeParty> -->


      <!-- ****************** TaxRepresentative Party ********************* -->
      <!-- <cac:TaxRepresentativeParty>
        <cac:PartyName>
          <cbc:Name>Tax handling company AS</cbc:Name>
        </cac:PartyName>
        <cac:PostalAddress>
          <cbc:StreetName>Regent street</cbc:StreetName>
          <cbc:AdditionalStreetName>Front door</cbc:AdditionalStreetName>
          <cbc:CityName>Newtown</cbc:CityName>
          <cbc:PostalZone>101</cbc:PostalZone>
          <cbc:CountrySubentity>RegionC</cbc:CountrySubentity>
          <cac:Country>

            <cbc:IdentificationCode>NO</cbc:IdentificationCode>
          </cac:Country>
        </cac:PostalAddress>
        <cac:PartyTaxScheme>

          <cbc:CompanyID>NO999999999MVA</cbc:CompanyID>
          <cac:TaxScheme>
            <cbc:ID>VAT</cbc:ID>
          </cac:TaxScheme>
        </cac:PartyTaxScheme>
      </cac:TaxRepresentativeParty> -->

      <!-- ****************** Delivery ********************* -->
      <!-- <cac:Delivery>
        <cbc:ActualDeliveryDate>2013-06-15</cbc:ActualDeliveryDate>
        <cac:DeliveryLocation>

          <cbc:ID schemeID="0088">6754238987643</cbc:ID>
        </cac:DeliveryLocation>
      </cac:Delivery> -->

      <!-- ****************** PaymentMeans ********************* -->
      <xsl:call-template name="PaymentMeans">
        <xsl:with-param name="PaymentMeansCode" select="$PaymentMeansCode" />
        <xsl:with-param name="PaymentID" select="$PaymentID" />
        <xsl:with-param name="PayeeFinancialAccountID" select="$PayeeFinancialAccountID" />
        <!-- <xsl:with-param name="FinancialInstitutionBranchID" select="$FinancialInstitutionBranchID" /> -->
      </xsl:call-template>
      <xsl:call-template name="PaymentMeans">
        <xsl:with-param name="PaymentMeansCode" select="$PaymentMeansCode" />
        <xsl:with-param name="PaymentID" select="$PaymentID" />
        <xsl:with-param name="PayeeFinancialAccountIBAN" select="$PayeeFinancialAccountIBAN" />
        <!-- <xsl:with-param name="FinancialInstitutionBranchID" select="$FinancialInstitutionBranchID" /> -->
      </xsl:call-template>
      

      <!-- ****************** PaymentTerms ********************* -->
      <!-- <cac:PaymentTerms>		
        <cbc:Note>2 % discount if paid within 2 days. Penalty percentage 10% from due date</cbc:Note>
      </cac:PaymentTerms> -->

      <!-- ****************** Allowance changes Template ********************* -->
      <!-- <xsl:for-each select="SOMETHING">
        <xsl:call-template name="AllowanceCharge" />
      </xsl:for-each> -->

      <!-- ****************** TaxTotal Template ********************* -->
      <xsl:call-template name="TaxTotal">
        <xsl:with-param name="currencyID" select="$globalCurrencyCode" />
        <xsl:with-param name="TaxAmount" select="$TaxAmount" />
      </xsl:call-template>

      <!-- ****************** LegalMonetaryTotal Template ********************* -->
      <xsl:call-template name="LegalMonetaryTotal">
        <xsl:with-param name="currencyID" select="$globalCurrencyCode"/>
        <xsl:with-param name="LineExtensionAmount" select="$LineExtensionAmount"/>
        <xsl:with-param name="TaxExclusiveAmount" select="$TaxExclusiveAmount"/>
        <xsl:with-param name="TaxInclusiveAmount" select="$TaxInclusiveAmount"/>
        <xsl:with-param name="AllowanceTotalAmount" select="$AllowanceTotalAmount"/>
        <xsl:with-param name="ChargeTotalAmount" select="$ChargeTotalAmount"/>
        <xsl:with-param name="PrepaidAmount" select="$PrepaidAmount"/>
        <xsl:with-param name="PayableRoundingAmount" select="$PayableRoundingAmount"/>
        <xsl:with-param name="PayableAmount" select="$PayableAmount"/>
      </xsl:call-template>

      <!-- ***************** Line template ********************** -->
      <!-- Taxcode scheme: https://docs.peppol.eu/poacc/billing/3.0/codelist/UNCL5305/ -->
      <xsl:for-each select="/ocr_data/lines/line">
        <xsl:variable name="lineCount" select="position()"/>
        <xsl:call-template name="InvoiceLine">
          <xsl:with-param name="ID" select="$lineCount" />
          <xsl:with-param name="InvoicedQuantity" select="*[local-name() = $fieldSchema_lineQuantity]" />
          <xsl:with-param name="currencyID" select="$globalCurrencyCode" />
          <xsl:with-param name="LineExtensionAmount" select="*[local-name() = $fieldSchema_lineNetAmount]" />
          <xsl:with-param name="ItemName" select="*[local-name() = $fieldSchema_lineDescription]" />
          <xsl:with-param name="PriceAmount">
              <xsl:choose>
                <xsl:when test="number(*[local-name() = $fieldSchema_linePrice])">
                  <xsl:value-of select="number(*[local-name() = $fieldSchema_linePrice])"/>
                </xsl:when>
                <xsl:when test="
                    number(*[local-name() = $fieldSchema_lineNetAmount])
                      div number(*[local-name() = $fieldSchema_lineQuantity])">
                    <xsl:value-of select="
                      number(*[local-name() = $fieldSchema_lineNetAmount])
                        div number(*[local-name() = $fieldSchema_lineQuantity])
                    "/>
                </xsl:when>
                <xsl:otherwise>
                  
                </xsl:otherwise>
              </xsl:choose>
          </xsl:with-param>
          <xsl:with-param name="ItemPriceBaseQuantity"></xsl:with-param>
          <xsl:with-param name="SellersItemIdentification" select="*[local-name() = $fieldSchema_productNo]" />
          <xsl:with-param name="TaxSchemeCode" select="*[local-name() = $fieldSchema_taxCodeScheme]" />
          <xsl:with-param name="TaxPercent" select="*[local-name() = $fieldSchema_taxPercent]" />
        </xsl:call-template>
      </xsl:for-each>
      <!-- <xsl:call-template name="InvoiceLineAllowanceChange" /> -->

      <xsl:if test="$DebugIncludeOriginal = 1">
        <originalXML>
          <xsl:copy-of select="."/>
        </originalXML>
      </xsl:if>
    </Invoice>
  </xsl:template>


  <xsl:template name="PaymentMeans"
      xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"
      xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"
  >
    <xsl:param name="PaymentMeansCode" />
    <xsl:param name="PaymentID" />
    <xsl:param name="PayeeFinancialAccountID" />
    <xsl:param name="PayeeFinancialAccountIBAN" />
    <xsl:param name="FinancialInstitutionBranchID" />
    <xsl:if test="
      ($PaymentMeansCode and string-length($PaymentMeansCode) > 0)
      or ($PaymentID and string-length($PaymentID) > 0)
    ">
      <cac:PaymentMeans>

        <xsl:if test="$PaymentMeansCode and string-length($PaymentMeansCode) > 0">
          <cbc:PaymentMeansCode>
            <xsl:value-of select="$PaymentMeansCode"/>
          </cbc:PaymentMeansCode>
        </xsl:if>
        <xsl:if test="$PaymentID and string-length($PaymentID) > 0">
          <cbc:PaymentID>
            <xsl:value-of select="translate($PaymentID,' ','')"/>
          </cbc:PaymentID>
        </xsl:if>

        <xsl:if test="$PayeeFinancialAccountID and string-length($PayeeFinancialAccountID) > 0">
          <cac:PayeeFinancialAccount>
            <cbc:ID>
                 <xsl:value-of select="translate($PayeeFinancialAccountID, translate($PayeeFinancialAccountID,'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-',''),'')" />
            </cbc:ID>
            
            <xsl:if test="$FinancialInstitutionBranchID and string-length($FinancialInstitutionBranchID) > 0">
              <cac:FinancialInstitutionBranch>
                <cbc:ID>
                  <xsl:value-of select="$FinancialInstitutionBranchID"/>
                </cbc:ID>
              </cac:FinancialInstitutionBranch>
            </xsl:if>

          </cac:PayeeFinancialAccount>
        </xsl:if>
        <!-- Egen for IBAN-->
        <xsl:if test="$PayeeFinancialAccountIBAN and string-length($PayeeFinancialAccountIBAN) > 0">
          <cac:PayeeFinancialAccount>
            <cbc:ID schemeID="IBAN">
              <xsl:value-of select="translate($PayeeFinancialAccountIBAN, translate($PayeeFinancialAccountIBAN,'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-',''),'')" />
            </cbc:ID>
            
            <xsl:if test="$FinancialInstitutionBranchID and string-length($FinancialInstitutionBranchID) > 0">
              <cac:FinancialInstitutionBranch>
                <cbc:ID>
                  <xsl:text>IBAN</xsl:text>
                </cbc:ID>
              </cac:FinancialInstitutionBranch>
            </xsl:if>
            
          </cac:PayeeFinancialAccount>
        </xsl:if>
      </cac:PaymentMeans>
    </xsl:if>
    
    
    
    
    
  </xsl:template>

  <xsl:template name="AccountingParty"
      xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"
      xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"
  >
      <xsl:param name="EndpointSchemeID" />
      <xsl:param name="Endpoint" />
      <xsl:param name="PartyIdentificationSchemeID" />
      <xsl:param name="PartyIdentification" />
      <xsl:param name="OrganisationNumberSchemeID" />
      <xsl:param name="OrganisationNumber" />
      <xsl:param name="TaxNumber" />
      <xsl:param name="TaxScheme" />
      <xsl:param name="PartyName" />
      <xsl:param name="StreetName" />
      <xsl:param name="AdditionalStreetName" />
      <xsl:param name="CityName" />
      <xsl:param name="PostalZone" />
      <xsl:param name="CountrySubentity" />
      <xsl:param name="CountryIdentificationCode" />
      <xsl:if test="$OrganisationNumber or $PartyName">
          <cac:Party>

            <xsl:if test="string-length($Endpoint) > 1">
              <cbc:EndpointID schemeID="{ $EndpointSchemeID }">
                <xsl:value-of select="$Endpoint" />
              </cbc:EndpointID>
            </xsl:if>

            <xsl:if test="string-length($PartyIdentification) > 1">
            <cac:PartyIdentification>
              <cbc:ID schemeID="{ $PartyIdentificationSchemeID }">
                <xsl:value-of select="$PartyIdentification" />
              </cbc:ID>
            </cac:PartyIdentification>
            </xsl:if>

            <xsl:if test="string-length($PartyName) > 1">
            <cac:PartyName>
              <cbc:Name>
                <xsl:value-of select="$PartyName" />
              </cbc:Name>
            </cac:PartyName>
            </xsl:if>

            <xsl:if test="
              string-length($StreetName) > 1 or
              string-length($AdditionalStreetName) > 1 or
              string-length($CityName) > 1 or
              string-length($PostalZone) > 1 or
              string-length($CountrySubentity) > 1 or
              string-length($CountryIdentificationCode) > 1">
              <cac:PostalAddress>
              <xsl:if test="string-length($StreetName) > 1">
                  <cbc:StreetName>
                    <xsl:value-of select="$StreetName" />
                  </cbc:StreetName>
                </xsl:if>
                <xsl:if test="string-length($AdditionalStreetName) > 1">
                  <cbc:AdditionalStreetName>
                    <xsl:value-of select="$AdditionalStreetName" />
                  </cbc:AdditionalStreetName>
                </xsl:if>
                <xsl:if test="string-length($CityName) > 1">
                  <cbc:CityName>
                    <xsl:value-of select="$CityName" />
                  </cbc:CityName>
                </xsl:if>
                <xsl:if test="string-length($PostalZone) > 1">
                  <cbc:PostalZone>
                    <xsl:value-of select="$PostalZone" />
                  </cbc:PostalZone>
                </xsl:if>
                <xsl:if test="string-length($CountrySubentity) > 1">
                  <cbc:CountrySubentity>
                    <xsl:value-of select="$CountrySubentity" />
                  </cbc:CountrySubentity>
                </xsl:if>
                <xsl:if test="string-length($CountryIdentificationCode) > 1">
                <cac:Country>
                  <cbc:IdentificationCode>
                    <xsl:value-of select="$CountryIdentificationCode" />
                  </cbc:IdentificationCode>
                </cac:Country>
                </xsl:if>
              </cac:PostalAddress>
            </xsl:if>

            <xsl:if test="string-length($TaxNumber) > 1">
              <cac:PartyTaxScheme>
                <cbc:CompanyID>
                  <xsl:value-of select="$TaxNumber"/>
                </cbc:CompanyID>
                <cac:TaxScheme>
                  <cbc:ID>
                    <xsl:value-of select="$TaxScheme"/>
                  </cbc:ID>
                </cac:TaxScheme>
              </cac:PartyTaxScheme>
            </xsl:if>

            <xsl:if test="string-length($OrganisationNumber) > 1 or string-length($PartyName) > 1">
              <cac:PartyLegalEntity>
                <xsl:if test="string-length($PartyName) > 1">
                  <cbc:RegistrationName>
                    <xsl:value-of select="$PartyName" />
                  </cbc:RegistrationName>
                </xsl:if>
                <xsl:if test="string-length($OrganisationNumber) > 1">
                  <cbc:CompanyID schemeID="{ $OrganisationNumberSchemeID }">
                    <xsl:value-of select="translate($OrganisationNumber, translate($OrganisationNumber,'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-',''),'')" />
                    
                  </cbc:CompanyID>
                </xsl:if>
              </cac:PartyLegalEntity>
            </xsl:if>

            <!-- <cac:Contact>
              <cbc:Name>John Doe</cbc:Name>
              <cbc:Telephone>5121230</cbc:Telephone>
              <cbc:ElectronicMail>john@buyercompany.no</cbc:ElectronicMail>
            </cac:Contact> -->

          </cac:Party>
      </xsl:if>
  </xsl:template>

  <xsl:template name="InvoiceLine"
      xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"
      xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2">
    <xsl:param name="ID" />
    <xsl:param name="InvoicedQuantity" />
    <xsl:param name="currencyID" />
    <xsl:param name="LineExtensionAmount" />
    <xsl:param name="ItemName" />
    <xsl:param name="PriceAmount" />
    <xsl:param name="ItemPriceBaseQuantity" />
    <xsl:param name="SellersItemIdentification" />
    <xsl:param name="TaxSchemeCode" />
    <xsl:param name="TaxPercent" />
    <cac:InvoiceLine>
      <xsl:if test="$ID">
        <cbc:ID>
          <xsl:value-of select="$ID"/>
        </cbc:ID>
      </xsl:if>
      <!-- 46 -->
      <xsl:if test="$InvoicedQuantity and string-length($InvoicedQuantity) > 0">
        <cbc:InvoicedQuantity>
          <xsl:value-of select="$InvoicedQuantity"/>
        </cbc:InvoicedQuantity>
      </xsl:if>
      <xsl:if test="$LineExtensionAmount and string-length($LineExtensionAmount) > 0">
        <cbc:LineExtensionAmount currencyID="{ $currencyID }">
          <xsl:value-of select=" format-number($LineExtensionAmount, '###0.00')"/>
        </cbc:LineExtensionAmount>
      </xsl:if>
      <xsl:if test="string-length($ItemName) > 0 or string-length($TaxPercent)">
        <cac:Item>
          <xsl:if test="$ItemName">
            <cbc:Name>
              <xsl:value-of select="$ItemName"/>
            </cbc:Name>
          </xsl:if>
          <xsl:if test="$SellersItemIdentification">
            <cac:SellersItemIdentification>
              <cbc:ID>
                <xsl:value-of select="$SellersItemIdentification" />
              </cbc:ID>
            </cac:SellersItemIdentification>
          </xsl:if>
          <xsl:if test="$TaxPercent">
          <cac:ClassifiedTaxCategory>
            <!-- 51 -->
            <xsl:if test="$TaxSchemeCode">
              <cbc:ID schemeID="UNCL5305">
                <xsl:value-of select="$TaxSchemeCode" />
              </cbc:ID>
            </xsl:if>
            <cbc:Percent>
              <xsl:value-of select=" format-number($TaxPercent, '###0.00')"/>
            </cbc:Percent>
            <cac:TaxScheme>
              <cbc:ID>VAT</cbc:ID>
            </cac:TaxScheme>
          </cac:ClassifiedTaxCategory>
          </xsl:if>
        </cac:Item>
      </xsl:if>
      <xsl:if test="string-length($PriceAmount) > 0 and ($PriceAmount = $PriceAmount)">
        <cac:Price>
          <cbc:PriceAmount currencyID="{ $currencyID }">
            <xsl:value-of select=" format-number($PriceAmount, '###0.00')"/>
          </cbc:PriceAmount>
          <xsl:if test="$ItemPriceBaseQuantity">
            <cbc:BaseQuantity>1</cbc:BaseQuantity>
          </xsl:if>
        </cac:Price>
      </xsl:if>
    </cac:InvoiceLine>
  </xsl:template>

  <!-- <xsl:template name="InvoiceLineAllowanceChange" as="">
    <cac:InvoiceLine>
      <cbc:ID>1</cbc:ID>
      <cbc:Note>Scratch on box</cbc:Note>

      <cbc:InvoicedQuantity unitCode="NAR">1</cbc:InvoicedQuantity>
      <cbc:LineExtensionAmount currencyID="NOK">1273</cbc:LineExtensionAmount>
      <cbc:AccountingCost>BookingCode001</cbc:AccountingCost>
      <cac:InvoicePeriod>
        <cbc:StartDate>2013-06-01</cbc:StartDate>
        <cbc:EndDate>2013-06-30</cbc:EndDate>
      </cac:InvoicePeriod>
      <cac:OrderLineReference>
        <cbc:LineID>1</cbc:LineID>
      </cac:OrderLineReference>
      

      
      <cac:AllowanceCharge>
        <cbc:ChargeIndicator>false</cbc:ChargeIndicator>
        <cbc:AllowanceChargeReason>Damage</cbc:AllowanceChargeReason>
        <cbc:Amount currencyID="NOK">12</cbc:Amount>
      </cac:AllowanceCharge>
      <cac:AllowanceCharge>
        <cbc:ChargeIndicator>true</cbc:ChargeIndicator>
        <cbc:AllowanceChargeReason>Testing</cbc:AllowanceChargeReason>
        <cbc:Amount currencyID="NOK">12</cbc:Amount>
      </cac:AllowanceCharge>
      <cac:Item>
        <cbc:Description>Processor: Intel Core 2 Duo SU9400 LV (1.4GHz). RAM: 3MB. Screen
          1440x900</cbc:Description>
        <cbc:Name>Laptop computer</cbc:Name>
        <cac:SellersItemIdentification>
          <cbc:ID>JB007</cbc:ID>
        </cac:SellersItemIdentification>
        <cac:StandardItemIdentification>

          <cbc:ID schemeID="0088">1234567890124</cbc:ID>
        </cac:StandardItemIdentification>
        <cac:OriginCountry>

          <cbc:IdentificationCode>DE</cbc:IdentificationCode>
        </cac:OriginCountry>
        <cac:CommodityClassification>

          <cbc:ItemClassificationCode listID="MP">12344321</cbc:ItemClassificationCode>
        </cac:CommodityClassification>
        <cac:CommodityClassification>

          <cbc:ItemClassificationCode listID="STI">65434568</cbc:ItemClassificationCode>
        </cac:CommodityClassification>
        <cac:ClassifiedTaxCategory>

          <cbc:ID>S</cbc:ID>
          <cbc:Percent>25</cbc:Percent>
          <cac:TaxScheme>
            <cbc:ID>VAT</cbc:ID>
          </cac:TaxScheme>
        </cac:ClassifiedTaxCategory>
        <cac:AdditionalItemProperty>
          <cbc:Name>Color</cbc:Name>
          <cbc:Value>Black</cbc:Value>
        </cac:AdditionalItemProperty>
        

        
      </cac:Item>
      <cac:Price>
        <cbc:PriceAmount currencyID="NOK">1273</cbc:PriceAmount>
        <cbc:BaseQuantity>1</cbc:BaseQuantity>
        <cac:AllowanceCharge>
          <cbc:ChargeIndicator>false</cbc:ChargeIndicator>
          <cbc:Amount currencyID="NOK">227</cbc:Amount>
          <cbc:BaseAmount currencyID="NOK">1500</cbc:BaseAmount>
        </cac:AllowanceCharge>
      </cac:Price>
    </cac:InvoiceLine>
  </xsl:template> -->

  <xsl:template name="LegalMonetaryTotal"
      xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"
      xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2">
    <xsl:param name="currencyID" />
    <xsl:param name="LineExtensionAmount" />
    <xsl:param name="TaxExclusiveAmount" />
    <xsl:param name="TaxInclusiveAmount" />
    <xsl:param name="AllowanceTotalAmount" />
    <xsl:param name="ChargeTotalAmount" />
    <xsl:param name="PrepaidAmount" />
    <xsl:param name="PayableRoundingAmount" />
    <xsl:param name="PayableAmount" />

    <cac:LegalMonetaryTotal>
      <xsl:if test="string-length($LineExtensionAmount) > 1">
        <cbc:LineExtensionAmount currencyID="{ $currencyID }">
          
          <xsl:value-of select=" format-number($LineExtensionAmount, '###0.00')"/>         
        </cbc:LineExtensionAmount>
      </xsl:if>
      <xsl:if test="string-length($TaxExclusiveAmount) > 1">
        <cbc:TaxExclusiveAmount currencyID="{ $currencyID }">
          <xsl:value-of select=" format-number($TaxExclusiveAmount, '###0.00')"/>
        </cbc:TaxExclusiveAmount>
      </xsl:if>
      <xsl:if test="string-length($TaxInclusiveAmount) > 1">
        <cbc:TaxInclusiveAmount currencyID="{ $currencyID }">
          <xsl:value-of select=" format-number($TaxInclusiveAmount, '###0.00')"/>
        </cbc:TaxInclusiveAmount>
      </xsl:if>
      <xsl:if test="string-length($AllowanceTotalAmount) > 1">
        <cbc:AllowanceTotalAmount currencyID="{ $currencyID }">
          <xsl:value-of select="$AllowanceTotalAmount" />
        </cbc:AllowanceTotalAmount>
      </xsl:if>
      <xsl:if test="string-length($ChargeTotalAmount) > 1">
        <cbc:ChargeTotalAmount currencyID="{ $currencyID }">
          <xsl:value-of select="$ChargeTotalAmount" />
        </cbc:ChargeTotalAmount>
      </xsl:if>
      <xsl:if test="string-length($PrepaidAmount) > 1">
        <cbc:PrepaidAmount currencyID="{ $currencyID }">
          <xsl:value-of select="$PrepaidAmount" />
        </cbc:PrepaidAmount>
      </xsl:if>
      <xsl:if test="string-length($PayableRoundingAmount) > 1">
        <cbc:PayableRoundingAmount currencyID="{ $currencyID }">
          <xsl:value-of select=" format-number($PayableRoundingAmount, '###0.00')"/>
        </cbc:PayableRoundingAmount>
      </xsl:if>
      <xsl:if test="string-length($PayableAmount) > 1">
        <cbc:PayableAmount currencyID="{ $currencyID }">
          <xsl:value-of select=" format-number($PayableAmount, '###0.00')"/>
        </cbc:PayableAmount>
      </xsl:if>
    </cac:LegalMonetaryTotal>
  </xsl:template>

  <xsl:template name="dateConvertddDOTmmDOTyyyy">
    <xsl:param name="originalDate" />
    <xsl:value-of select="substring($originalDate, 7, 4)"/>
    <xsl:text>-</xsl:text>
    <xsl:value-of select="substring($originalDate, 4, 2)"/>
    <xsl:text>-</xsl:text>
    <xsl:value-of select="substring($originalDate, 1, 2)"/>
  </xsl:template>

  <xsl:template name="TaxTotal"
      xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"
      xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2">

    <xsl:param name="currencyID" />
    <xsl:param name="TaxAmount" />
    
      <cac:TaxTotal>
        
        <cbc:TaxAmount currencyID="{ $currencyID }">
            <xsl:value-of select=" format-number($TaxAmount, '###0.00')"/>        
        </cbc:TaxAmount>
    
        <!-- <cac:TaxSubtotal>
          <cbc:TaxableAmount currencyID="NOK">1460.5</cbc:TaxableAmount>
          <cbc:TaxAmount currencyID="NOK">365.13</cbc:TaxAmount>
          <cac:TaxCategory>

            <cbc:ID>S</cbc:ID>
            <cbc:Percent>25</cbc:Percent>
            <cac:TaxScheme>
              <cbc:ID>VAT</cbc:ID>
            </cac:TaxScheme>
          </cac:TaxCategory>
        </cac:TaxSubtotal>
        <cac:TaxSubtotal>
          <cbc:TaxableAmount currencyID="NOK">1</cbc:TaxableAmount>
          <cbc:TaxAmount currencyID="NOK">0.15</cbc:TaxAmount>
          <cac:TaxCategory>

            <cbc:ID>S</cbc:ID>
            <cbc:Percent>15</cbc:Percent>
            <cac:TaxScheme>
              <cbc:ID>VAT</cbc:ID>
            </cac:TaxScheme>
          </cac:TaxCategory>
        </cac:TaxSubtotal>
        <cac:TaxSubtotal>
          <cbc:TaxableAmount currencyID="NOK">-25</cbc:TaxableAmount>
          <cbc:TaxAmount currencyID="NOK">0</cbc:TaxAmount>
          <cac:TaxCategory>

            <cbc:ID>E</cbc:ID>
            <cbc:Percent>0</cbc:Percent>
            <cbc:TaxExemptionReason>Exempt New Means of Transport</cbc:TaxExemptionReason>
            <cac:TaxScheme>
              <cbc:ID>VAT</cbc:ID>
            </cac:TaxScheme>
          </cac:TaxCategory>
        </cac:TaxSubtotal> -->
      </cac:TaxTotal>
    
  </xsl:template>

  <!-- <xsl:template name="AllowanceCharge" as="">
    <cac:AllowanceCharge>
      <cbc:ChargeIndicator>false</cbc:ChargeIndicator>

      <cbc:AllowanceChargeReasonCode>95</cbc:AllowanceChargeReasonCode>
      <cbc:AllowanceChargeReason>Promotion discount</cbc:AllowanceChargeReason>
      <cbc:Amount currencyID="NOK">100</cbc:Amount>
      <cac:TaxCategory>

        <cbc:ID>S</cbc:ID>
        <cbc:Percent>25</cbc:Percent>
        <cac:TaxScheme>
          <cbc:ID>VAT</cbc:ID>
        </cac:TaxScheme>
      </cac:TaxCategory>
    </cac:AllowanceCharge>    
  </xsl:template> -->

</xsl:stylesheet>