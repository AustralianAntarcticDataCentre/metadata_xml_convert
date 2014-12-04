<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:gmd="http://www.isotc211.org/2005/gmd"
	xmlns:srv="http://www.isotc211.org/2005/srv"
	xmlns:gco="http://www.isotc211.org/2005/gco"
	xmlns:gts='http://www.isotc211.org/2005/gts'
	xmlns:geonet="http://www.fao.org/geonetwork"
	xmlns:gmx="http://www.isotc211.org/2005/gmx"
	xmlns:gml="http://www.opengis.net/gml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://ands.org.au/standards/rif-cs/registryObjects">

	<!-- stylesheet to convert iso19139 in OAI-PMH ListRecords response to RIF-CS -->
	<xsl:output method="xml" version="1.0" encoding="UTF-8" omit-xml-declaration="yes" indent="yes"/>
	<xsl:strip-space elements='*'/>
	<xsl:param name="global_originatingSource" select="'http://data.aad.gov.au/aadc'"/>
	<xsl:param name="global_baseURI" select="'http://data.aad.gov.au/aadc'"/>
	<xsl:param name="global_group" select="'Australian Antarctic Data Centre'"/>
	<xsl:param name="global_publisherName" select="'Australian Antarctic Data Centre'"/>
	<xsl:param name="global_publisherPlace" select="'Canberra'"/>
	<xsl:variable name="anzsrcCodelist" select="document('anzsrc-codelist.xml')"/>
	<xsl:variable name="licenseCodelist" select="document('license-codelist.xml')"/>
	<xsl:variable name="gmdCodelists" select="document('codelists.xml')"/>

	<xsl:template match="/">
		<xsl:apply-templates/>
	</xsl:template>

	 <xsl:template match="root">
		<xsl:apply-templates/>
	</xsl:template>


	<!-- =============================== -->
	<!-- RegistryObjects (root) Template -->
	<!-- =============================== -->

	<xsl:template match="gmd:MD_Metadata">
		<!--registryObjects-->
			<!--xsl:attribute name="xsi:schemaLocation">
				<xsl:text>http://ands.org.au/standards/rif-cs/registryObjects http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd</xsl:text>
			</xsl:attribute-->
			<xsl:apply-templates select="." mode="collection"/>
			<xsl:apply-templates select="." mode="party"/>
		<!--/registryObjects-->
	</xsl:template>

	<xsl:template match="node()"/>


	<!-- ================================== -->
	<!-- Collection RegistryObject Template -->
	<!-- ================================== -->

	<xsl:template match="gmd:MD_Metadata" mode="collection">
		<!-- construct parameters for values that are required in more than one place in the output xml-->
		<xsl:param name="dataSetURI" select="gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine[1]/gmd:CI_OnlineResource/gmd:linkage/gmd:URL"/>

		<registryObject>
			<xsl:attribute name="group">
				<xsl:value-of select="$global_group"/>
			</xsl:attribute>
			<xsl:apply-templates select="gmd:fileIdentifier" mode="collection_key"/>

			<originatingSource>
				<xsl:value-of select="$global_originatingSource"/>
			</originatingSource>

			<collection>
				<xsl:apply-templates select="gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue"
					mode="collection_type_attribute"/>

				<xsl:apply-templates select="gmd:fileIdentifier"
					mode="collection_identifier"/>

				<xsl:apply-templates select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:identifier"
					mode="collection_identifier"/>

				<xsl:apply-templates select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title"
					mode="collection_name"/>

				<xsl:apply-templates select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:date"
					mode="collection_dates"/>

				<xsl:apply-templates select="gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine[1]/gmd:CI_OnlineResource/gmd:linkage/gmd:URL"
					mode="collection_location"/>

				<xsl:for-each-group select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:individualName))) and
					(string-length(normalize-space(gmd:role/gmd:CI_RoleCode/@codeListValue)))]"
					group-by="gmd:individualName">
					<xsl:apply-templates select="."
						mode="collection_related_object"/>
				</xsl:for-each-group>

				<xsl:for-each-group select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:organisationName)) and not(string-length(normalize-space(gmd:individualName)))) and
					(string-length(normalize-space(gmd:role/gmd:CI_RoleCode/@codeListValue)))]"
					group-by="gmd:organisationName">
					<xsl:apply-templates select="."
						mode="collection_related_object"/>
				</xsl:for-each-group>

				<xsl:apply-templates select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:topicCategory/gmd:MD_TopicCategoryCode"
					mode="collection_subject"/>

				<xsl:apply-templates select="gmd:identificationInfo/gmd:MD_DataIdentification"
					mode="collection_subject"/>

				<xsl:apply-templates select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:abstract"
					mode="collection_description"/>

				<xsl:apply-templates select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox"
					mode="collection_coverage_spatial"/>

				<xsl:apply-templates select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent"
					mode="collection_coverage_temporal"/>

				<xsl:variable name="organisationOwnerName">
					<xsl:apply-templates select="gmd:identificationInfo/gmd:MD_DataIdentification" mode="variable_owner_name"/>
				</xsl:variable>

				<xsl:variable name="individualOwnerName">
					<xsl:apply-templates select="gmd:identificationInfo/gmd:MD_DataIdentification" mode="variable_individual_name"/>
				</xsl:variable>

				<xsl:variable name="publishDate">
					<xsl:apply-templates select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation" mode="variable_publish_date"/>
				</xsl:variable>

				<xsl:apply-templates select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceConstraints/gmd:MD_LegalConstraints[
					exists(gmd:otherConstraints)]"
					mode="collection_rights_licence"/>

				<xsl:apply-templates select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceConstraints/gmd:MD_LegalConstraints[
					exists(gmd:useConstraints) and exists(gmd:otherConstraints)]"
					mode="collection_rights_rightsStatement"/>

				<xsl:apply-templates select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceConstraints/gmd:MD_LegalConstraints[
					exists(gmd:accessConstraints) and exists(gmd:otherConstraints)]"
					mode="collection_rights_accessRights"/>

				<xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation">
				   <xsl:call-template name="collection_citationMetadata_citationInfo">
					   <xsl:with-param name="dataSetURI" select="$dataSetURI"/>
					   <xsl:with-param name="citation" select="."/>
				   </xsl:call-template>
				</xsl:for-each>
			</collection>
		</registryObject>
	</xsl:template>


	<!-- ============================= -->
	<!-- Party RegistryObject Template -->
	<!-- ============================= -->

	<xsl:template match="gmd:MD_Metadata" mode="party">
		<xsl:for-each-group select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:individualName))) and
			(string-length(normalize-space(gmd:role/gmd:CI_RoleCode/@codeListValue)))]"
			group-by="gmd:individualName">
			<xsl:call-template name="party">
				<xsl:with-param name="type">person</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each-group>

		<xsl:for-each-group select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:organisationName))) and
			(string-length(normalize-space(gmd:role/gmd:CI_RoleCode/@codeListValue)))]"
			group-by="gmd:organisationName">
			<xsl:call-template name="party">
				<xsl:with-param name="type">group</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each-group>
	</xsl:template>


	<!-- =========================================== -->
	<!-- Collection RegistryObject - Child Templates -->
	<!-- =========================================== -->

	<!-- Collection - Key Element  -->

	<xsl:template match="gmd:fileIdentifier" mode="collection_key">
		<key>
			<xsl:value-of select="concat($global_baseURI, '/', normalize-space(.))"/>
		</key>
	</xsl:template>


	<!-- Collection - Type Attribute -->

	<xsl:template match="gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue" mode="collection_type_attribute">
		<xsl:attribute name="type">
			<xsl:value-of select="."/>
		</xsl:attribute>
	</xsl:template>


	<!-- Collection - Identifier Element  -->

	<xsl:template match="gmd:fileIdentifier" mode="collection_identifier">
		<identifier>
			<xsl:attribute name="type">
				 <xsl:text>local</xsl:text>
			</xsl:attribute>
			<xsl:value-of select="normalize-space(.)"/>
		</identifier>
	</xsl:template>


	<xsl:template match="gmd:identifier" mode="collection_identifier">
		<xsl:variable name="code" select="normalize-space(gmd:MD_Identifier/gmd:code)"></xsl:variable>
		<xsl:if test="string-length($code)">
			<identifier>
				<xsl:attribute name="type">
					<xsl:choose>
						<xsl:when test="contains(lower-case($code), 'doi')">
							<xsl:text>doi</xsl:text>
						</xsl:when>
						<xsl:when test="contains(lower-case($code), 'http')">
							<xsl:text>uri</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>local</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:value-of select="$code"/>
			</identifier>
		</xsl:if>
	</xsl:template>


	<!-- Collection - Name Element  -->

	<xsl:template match="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title" mode="collection_name">
		<name>
			<xsl:attribute name="type">
				 <xsl:text>primary</xsl:text>
			</xsl:attribute>
			<namePart>
				 <xsl:value-of select="."/>
			</namePart>
		</name>
	</xsl:template>


	<!-- Collection - Address Electronic Element  -->

	<xsl:template match="gmd:URL" mode="collection_location">
	   <location>
			<address>
				<electronic>
					<xsl:attribute name="type">
						<xsl:text>url</xsl:text>
					</xsl:attribute>
					<value>
						<xsl:value-of select="."/>
					</value>
				</electronic>
			</address>
	   </location>
	</xsl:template>


	<!-- Collection - Dates Element -->

	<xsl:template
		match="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:date"
		mode="collection_dates">
		<xsl:variable name="dateTime" select="normalize-space(gmd:CI_Date/gmd:date/gco:Date)"/>
		<xsl:variable name="dateCode"
			select="normalize-space(gmd:CI_Date/gmd:dateType/gmd:CI_DateTypeCode/@codeListValue)"/>
		<xsl:variable name="transformedDateCode">
			<xsl:choose>
				<xsl:when test="contains($dateCode, 'creation')">
					<xsl:text>created</xsl:text>
				</xsl:when>
				<xsl:when test="contains($dateCode, 'publication')">
					<xsl:text>issued</xsl:text>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:if test="(string-length($dateTime) > 0) and (string-length($transformedDateCode) > 0)">
			<dates>
				<xsl:attribute name="type">
					<xsl:value-of select="$transformedDateCode"/>
				</xsl:attribute>
				<date>
					<xsl:attribute name="type">
						<xsl:text>dateFrom</xsl:text>
					</xsl:attribute>
					<xsl:attribute name="dateFormat">
						<xsl:text>W3CDTF</xsl:text>
					</xsl:attribute>
					<xsl:value-of select="$dateTime"/>
				</date>
			</dates>
		</xsl:if>
	</xsl:template>


	<!-- Collection - Related Object (Organisation or Individual) Element -->

	<xsl:template match="gmd:CI_ResponsibleParty" mode="collection_related_object">
		<xsl:variable name="transformedName">
			<xsl:call-template name="transform">
				<xsl:with-param name="inputString" select="current-grouping-key()"/>
			</xsl:call-template>
		</xsl:variable>
		<relatedObject>
			<key>
				<xsl:value-of select="concat($global_baseURI,'/', translate(normalize-space($transformedName),' ',''))"/>
			</key>
			<xsl:for-each-group select="current-group()/gmd:role" group-by="gmd:CI_RoleCode/@codeListValue">
				<xsl:variable name="code">
					<xsl:value-of select="current-grouping-key()"/>
				</xsl:variable>
				<relation>
					<xsl:attribute name="type">
						<xsl:value-of select="$code"/>
					</xsl:attribute>
				</relation>
			</xsl:for-each-group>
		</relatedObject>
	</xsl:template>


	<!-- Collection - Subject Element -->

	<xsl:template match="gmd:MD_DataIdentification" mode="collection_subject">
		<xsl:message>gmd:MD_Keywords</xsl:message>

		<xsl:for-each select="gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword">
			<subject type="local">
				<xsl:value-of select="normalize-space(.)"/>
			</subject>
		</xsl:for-each>

		<xsl:variable name="subject_sequence" as="xs:string*">
			<xsl:for-each select="gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword">
				<xsl:call-template name="splitText_sequence">
					<xsl:with-param name="string" select="."/>
					<xsl:with-param name="separator" select="'&gt;'"/>
				</xsl:call-template>
			</xsl:for-each>
		</xsl:variable>
		<xsl:for-each select="distinct-values($subject_sequence)">
		   <xsl:message select="lower-case(normalize-space(.))"/>
			<xsl:variable name="code"
				select="(normalize-space($anzsrcCodelist/gmx:CT_CodelistCatalogue/gmx:codelistItem/gmx:CodeListDictionary[@gml:id='ANZSRCCode']/gmx:codeEntry/gmx:CodeDefinition/gml:identifier[lower-case(following-sibling::gml:name) = lower-case(normalize-space(.))]))[1]"/>
			<xsl:if test="string-length($code) > 0">
				<subject>
					<xsl:attribute name="type">
						<xsl:value-of select="'anzsrc-for'"/>
					</xsl:attribute>
					<xsl:value-of select="$code"/>
				</subject>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>


   <xsl:template match="gmd:MD_TopicCategoryCode" mode="collection_subject">
	   <xsl:if test="string-length(normalize-space(.)) > 0">
			<subject type="local">
				<xsl:value-of select="."></xsl:value-of>
			</subject>
	   </xsl:if>
	</xsl:template>


	<!-- Collection - Decription Element -->

	<xsl:template match="gmd:abstract" mode="collection_description">
		<description type="brief">
		   <xsl:value-of select="."/>
		</description>
	</xsl:template>


	<!-- Collection - Coverage Spatial Element -->

	<xsl:template match="gmd:EX_TemporalExtent" mode="collection_coverage_temporal">
		<xsl:if test="string-length(normalize-space(gmd:extent/gml:TimePeriod/gml:begin/gml:TimeInstant/gml:timePosition)) or
					  string-length(normalize-space(gmd:extent/gml:TimePeriod/gml:end/gml:TimeInstant/gml:timePosition))">
			<coverage>
				<temporal>
					<xsl:if test="string-length(normalize-space(gmd:extent/gml:TimePeriod/gml:begin/gml:TimeInstant/gml:timePosition))">
						<date>
							<xsl:attribute name="dateFormat">
								<xsl:text>W3CDTF</xsl:text>
							</xsl:attribute>
							<xsl:attribute name="type">
								<xsl:text>dateFrom</xsl:text>
							</xsl:attribute>
							<xsl:value-of select="gmd:extent/gml:TimePeriod/gml:begin/gml:TimeInstant/gml:timePosition"/>
						</date>
					</xsl:if>
					<xsl:if test="string-length(normalize-space(gmd:extent/gml:TimePeriod/gml:end/gml:TimeInstant/gml:timePosition))">
						<date>
							<xsl:attribute name="dateFormat">
								<xsl:text>W3CDTF</xsl:text>
							</xsl:attribute>
							<xsl:attribute name="type">
								<xsl:text>dateTo</xsl:text>
							</xsl:attribute>
							<xsl:value-of select="gmd:extent/gml:TimePeriod/gml:end/gml:TimeInstant/gml:timePosition"/>
						</date>
					</xsl:if>
				</temporal>
			</coverage>
		</xsl:if>
	</xsl:template>


	<!-- Collection - Coverage Spatial Element -->

	<xsl:template match="gmd:EX_GeographicBoundingBox" mode="collection_coverage_spatial">
		<xsl:variable name="spatialString">
			   <xsl:variable name="horizontal">
					<xsl:if test="(string-length(normalize-space(gmd:northBoundLatitude/gco:Decimal))) and
								  (string-length(normalize-space(gmd:southBoundLatitude/gco:Decimal))) and
								  (string-length(normalize-space(gmd:westBoundLongitude/gco:Decimal))) and
								  (string-length(normalize-space(gmd:eastBoundLongitude/gco:Decimal)))">
						<xsl:value-of select="normalize-space(concat('northlimit=',gmd:northBoundLatitude/gco:Decimal,'; southlimit=',gmd:southBoundLatitude/gco:Decimal,'; westlimit=',gmd:westBoundLongitude/gco:Decimal,'; eastLimit=',gmd:eastBoundLongitude/gco:Decimal))"/>
					</xsl:if>
				</xsl:variable>
				<xsl:variable name="vertical">
					<xsl:if test="
						(string-length(normalize-space(gmd:EX_VerticalExtent/gmd:maximumValue/gco:Real))) and
						(string-length(normalize-space(gmd:EX_VerticalExtent/gmd:minimumValue/gco:Real)))">
						<xsl:value-of select="normalize-space(concat('; uplimit=',gmd:EX_VerticalExtent/gmd:maximumValue/gco:Real,'; downlimit=',gmd:EX_VerticalExtent/gmd:minimumValue/gco:Real))"/>
					</xsl:if>
				</xsl:variable>
				<xsl:value-of select="concat($horizontal, $vertical, '; projection=WGS84')"/>
		</xsl:variable>
		 <coverage>
			<spatial>
				<xsl:attribute name="type">
					<xsl:text>iso19139dcmiBox</xsl:text>
				</xsl:attribute>
				<xsl:value-of select="$spatialString"/>
			</spatial>
			 <spatial>
				 <xsl:attribute name="type">
					 <xsl:text>text</xsl:text>
				 </xsl:attribute>
				 <xsl:value-of select="$spatialString"/>
			 </spatial>
		</coverage>
	</xsl:template>


	<!-- Variable - Owner Name -->

	<xsl:template match="gmd:MD_DataIdentification" mode="variable_owner_name">
		<xsl:call-template name="childValueForRole">
			<xsl:with-param name="roleSubstring">
				<xsl:text>owner</xsl:text>
			</xsl:with-param>
			<xsl:with-param name="childElementName">
				<xsl:text>organisationName</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>


	<!-- Variable - Individual Name -->

	<xsl:template match="gmd:MD_DataIdentification" mode="variable_individual_name">
		<xsl:call-template name="childValueForRole">
			<xsl:with-param name="roleSubstring">
				<xsl:text>owner</xsl:text>
			</xsl:with-param>
			<xsl:with-param name="childElementName">
				<xsl:text>individualName</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>


	<!-- Variable - Publish Date -->

	<xsl:template match="gmd:MD_DataIdentification/gmd:citation" mode="variable_publish_date">
		<xsl:for-each select="gmd:CI_Citation/gmd:date/gmd:CI_Date">
			<xsl:if test="contains(lower-case(normalize-space(gmd:dateType/gmd:CI_DateTypeCode/@codeListValue)), 'publication')">
				<xsl:value-of select="normalize-space(gmd:date/gco:Date)"/>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>


	<!-- Collection - Rights Licence Element -->

	<xsl:template match="gmd:MD_LegalConstraints" mode="collection_rights_licence">
		<xsl:variable name="otherConstraints" select="normalize-space(gmd:otherConstraints)"/>
		<xsl:if test="string-length($otherConstraints)">
			<xsl:if test="contains(lower-case($otherConstraints), 'picccby')">
				<rights>
					<!--licence><xsl:text disable-output-escaping="yes">&lt;![CDATA[&lt;a href="http://polarcommons.org/ethics-and-norms-of-data-sharing.php"&gt; &lt;img src="http://polarcommons.org/images/PIC_print_small.png" style="border-width:0; width:40px; height:40px;" alt="Polar Information Commons's PICCCBY license."/&gt;&lt;/a&gt;&lt;a rel="license" href="http://creativecommons.org/licenses/by/3.0/"&gt; &lt;img alt="Creative Commons License" style="border-width:0; width: 88px; height: 31px;" src="http://i.creativecommons.org/l/by/3.0/88x31.png" /&gt;&lt;/a&gt;]]&gt;</xsl:text>
					</licence-->
					<licence type="CC-BY" rightsUri="http://creativecommons.org/licenses/by/3.0/"/>
				</rights>
			</xsl:if>
		</xsl:if>
	</xsl:template>


	<!-- Collection - RightsStatement -->

	<xsl:template match="gmd:MD_LegalConstraints" mode="collection_rights_rightsStatement">
		<xsl:for-each select="gmd:otherConstraints">
			<!-- If there is text in other contraints, use this; otherwise, do nothing -->
			<xsl:if test="string-length(normalize-space(.))">
				<rights>
					<rightsStatement>
						<xsl:value-of select='normalize-space(.)'/>
					</rightsStatement>
				</rights>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>


	<!-- Collection - Rights AccessRights Element -->

	<xsl:template match="gmd:MD_LegalConstraints" mode="collection_rights_accessRights">
		<xsl:for-each select="gmd:otherConstraints">
			<!-- If there is text in other contraints, use this; otherwise, do nothing -->
			<xsl:if test="string-length(normalize-space(.))">
				<rights>
					<accessRights>
						<xsl:value-of select='normalize-space(.)'/>
					</accessRights>
				</rights>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>


	<!-- Collection - CitationInfo Element -->

	<xsl:template name="collection_citationMetadata_citationInfo">
		<xsl:param name="dataSetURI"/>
		<xsl:param name="citation"/>
		<!-- We can only accept one DOI; howerver, first we will find all -->
		<xsl:variable name="doiIdentifier_sequence" as="xs:string*">
			<xsl:call-template name="doiFromIdentifiers">
			<xsl:with-param name="identifier_sequence" as="xs:string*" select="gmd:identifier/gmd:MD_Identifier/gmd:code"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="identifierToUse">
			<xsl:choose>
				<xsl:when test="count($doiIdentifier_sequence) and string-length($doiIdentifier_sequence[1])">
					<xsl:value-of select="$doiIdentifier_sequence[1]"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$dataSetURI"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="typeToUse">
			<xsl:choose>
				<xsl:when test="count($doiIdentifier_sequence) and string-length($doiIdentifier_sequence[1])">
					<xsl:text>doi</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>uri</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<citationInfo>
			<citationMetadata>
				<xsl:if test="string-length($identifierToUse)">
					<identifier>
						<xsl:if test="string-length($typeToUse)">
							<xsl:attribute name="type">
								<xsl:value-of select='$typeToUse'/>
							</xsl:attribute>
						</xsl:if>
						<xsl:value-of select='$identifierToUse'/>
					</identifier>
				</xsl:if>

				<title>
					<xsl:value-of select="gmd:title"/>
				</title>

				<xsl:for-each select="gmd:date/gmd:CI_Date">
					<xsl:if test="contains(lower-case(normalize-space(gmd:dateType/gmd:CI_DateTypeCode/@codeListValue)), 'publication')">
						<date>
							<xsl:attribute name="type">
								<xsl:variable name="codelist" select="$gmdCodelists/codelists/codelist[@name = 'gmd:CI_DateTypeCode']"/>
								<xsl:variable name="codevalue" select="gmd:dateType/gmd:CI_DateTypeCode/@codeListValue"/>
								<xsl:value-of select="$codelist/entry[code = $codevalue]/description"/>
							</xsl:attribute>
							<xsl:value-of select="gmd:date/gco:Date"/>
						</date>
					</xsl:if>
				</xsl:for-each>

				<!-- Contributing individuals - note that we are ignoring those individuals where a role has not been specified -->
				<xsl:for-each-group
					select="gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:individualName))) and
					(string-length(normalize-space(gmd:role/gmd:CI_RoleCode/@codeListValue)))]"
					group-by="gmd:individualName">

					<xsl:variable name="individualName" select="normalize-space(current-grouping-key())"/>
					<xsl:variable name="isPublisher" as="xs:boolean*">
						<xsl:for-each-group select="current-group()/gmd:role" group-by="gmd:CI_RoleCode/@codeListValue">
							<xsl:if test="contains(lower-case(current-grouping-key()), 'publish')">
								<xsl:value-of select="true()"/>
							</xsl:if>
						</xsl:for-each-group>
					</xsl:variable>
					<xsl:if test="count($isPublisher) = 0">
						<contributor>
							<namePart>
								<xsl:value-of select="$individualName"/>
							</namePart>
						</contributor>
					</xsl:if>
				</xsl:for-each-group>

				<!-- Contributing organisations - included only when there is no individual name (in which case the individual has been included above)
						Note again that we are ignoring organisations where a role has not been specified -->
				<xsl:for-each-group
					select="gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[
							(string-length(normalize-space(gmd:organisationName))) and
							not(string-length(normalize-space(gmd:individualName))) and
							(string-length(normalize-space(gmd:role/gmd:CI_RoleCode/@codeListValue)))]"
					group-by="gmd:organisationName">

					<xsl:variable name="transformedOrganisationName">
						<xsl:call-template name="transform">
							<xsl:with-param name="inputString" select="normalize-space(current-grouping-key())"/>
						</xsl:call-template>
					</xsl:variable>

					<xsl:variable name="isPublisher" as="xs:boolean*">
						<xsl:for-each-group select="current-group()/gmd:role" group-by="gmd:CI_RoleCode/@codeListValue">
							<xsl:if test="contains(lower-case(current-grouping-key()), 'publish')">
								<xsl:value-of select="true()"/>
							</xsl:if>
						</xsl:for-each-group>
					</xsl:variable>
					<xsl:if test="count($isPublisher) = 0">
						<contributor>
							<namePart>
								<xsl:value-of select="$transformedOrganisationName"/>
							</namePart>
						</contributor>
					</xsl:if>
				</xsl:for-each-group>

				<xsl:variable name="publishName">
					<xsl:call-template name="publishNameToUse"/>
				</xsl:variable>

				<xsl:if test="string-length($publishName)">
					<publisher>
						<xsl:value-of select="$publishName"/>
					</publisher>
				</xsl:if>

				<xsl:variable name="publishPlace">
					<xsl:call-template name="publishPlaceToUse">
						<xsl:with-param name="publishNameToUse" select="$publishName"/>
					</xsl:call-template>
				</xsl:variable>

				<xsl:if test="string-length($publishPlace)">
					<placePublished>
						<xsl:value-of select="$publishPlace"/>
					</placePublished>
				</xsl:if>
			</citationMetadata>
		</citationInfo>
	</xsl:template>


	<!-- ====================================== -->
	<!-- Party RegistryObject - Child Templates -->
	<!-- ====================================== -->

	<!-- Party Registry Object (Individuals (person) and Organisations (group)) -->
	<xsl:template name="party">
		<xsl:param name="type"/>
		<registryObject group="{$global_group}">

			<xsl:variable name="transformedName">
				<xsl:call-template name="transform">
					<xsl:with-param name="inputString" select="current-grouping-key()"/>
				</xsl:call-template>
			</xsl:variable>

			<key>
				<xsl:value-of select="concat($global_baseURI, '/', translate(normalize-space($transformedName),' ',''))"/>
			</key>

			<originatingSource>
				<xsl:value-of select="$global_originatingSource"/>
			</originatingSource>

			<!-- Use the party type provided, except for exception:
				Because sometimes "Australian Antarctic Data Centre" or AADC, or "Australian Antarctic Division" or AAD, is used for an author, appearing in individualName,
				we want to make sure that we use 'group', not 'person', if this anomoly occurs -->

			<xsl:variable name="typeToUse">
				<xsl:choose>
					<xsl:when test="contains($transformedName, 'Australian Antarctic Division') or
									contains($transformedName, 'Australian Antarctic Data Centre')">
						<xsl:value-of>group</xsl:value-of>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$type"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<party type="{$typeToUse}">
				<name type="primary">
					<namePart>
						<xsl:value-of select="$transformedName"/>
					</namePart>
				</name>

				<!-- If we have are dealing with individual who has an organisation name:
					- leave out the address (so that it is on the organisation only); and
					- relate the individual to the organisation -->

				<!-- If we are dealing with an individual...-->
				<xsl:choose>
					<xsl:when test="contains($type, 'person')">
						<xsl:variable name="transformedOrganisationName">
							<xsl:call-template name="transform">
								<xsl:with-param name="inputString" select="gmd:organisationName"/>
							</xsl:call-template>
						</xsl:variable>

						<xsl:choose>
							<xsl:when test="string-length(normalize-space($transformedOrganisationName))">
								<!--  Individual has an organisation name, so related the individual to the organisation, and omit the address
									(the address will be included within the organisation to which this individual is related) -->
								<relatedObject>
									<key>
										<xsl:value-of select="concat($global_baseURI,'/', $transformedOrganisationName)"/>
									</key>
									<relation type="isMemberOf"/>
								</relatedObject>
							</xsl:when>

							<xsl:otherwise>
								<!-- Individual does not have an organisation name, so include the address here -->
								<xsl:call-template name="physicalAddress"/>
								<xsl:call-template name="phone"/>
								<xsl:call-template name="electronic"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>

					<xsl:otherwise>
						<!-- We are dealing with an organisation, so always include the address -->
						<xsl:call-template name="physicalAddress"/>
						<xsl:call-template name="phone"/>
						<xsl:call-template name="electronic"/>
					</xsl:otherwise>
				</xsl:choose>
			</party>
		</registryObject>
	</xsl:template>


	<xsl:template name="physicalAddress">
		<xsl:for-each select="current-group()">
			<xsl:sort
				select="count(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/child::*)"
				data-type="number" order="descending"/>

			<xsl:if test="position() = 1">
				<xsl:if test="count(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/child::*) > 0">
					<location>
						<address>
							<physical type="streetAddress">
								<addressPart type="addressLine">
									<xsl:value-of select="normalize-space(current-grouping-key())"/>
								</addressPart>

								<xsl:for-each select="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:deliveryPoint/gco:CharacterString[string-length(text()) > 0]">
									 <addressPart type="addressLine">
										 <xsl:value-of select="normalize-space(.)"/>
									 </addressPart>
								</xsl:for-each>

								 <xsl:if test="string-length(normalize-space(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:city))">
									  <addressPart type="suburbOrPlaceLocality">
										  <xsl:value-of select="normalize-space(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:city)"/>
									  </addressPart>
								 </xsl:if>

								 <xsl:if test="string-length(normalize-space(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:administrativeArea))">
									 <addressPart type="stateOrTerritory">
										 <xsl:value-of select="normalize-space(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:administrativeArea)"/>
									 </addressPart>
								 </xsl:if>

								 <xsl:if test="string-length(normalize-space(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:postalCode))">
									 <addressPart type="postCode">
										 <xsl:value-of select="normalize-space(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:postalCode)"/>
									 </addressPart>
								 </xsl:if>

								 <xsl:if test="string-length(normalize-space(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:country))">
									 <addressPart type="country">
										 <xsl:value-of select="normalize-space(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:country)"/>
									 </addressPart>
								 </xsl:if>
							</physical>
						</address>
					</location>
				</xsl:if>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>


	<xsl:template name="phone">
		<xsl:for-each select="current-group()">
			<xsl:sort
				select="count(gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/child::*)"
				data-type="number" order="descending"/>

			<xsl:if test="position() = 1">
				<xsl:if test="count(gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/child::*) > 0">
					 <xsl:for-each select="gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/gmd:voice/gco:CharacterString[string-length(text()) > 0]">
						 <location>
							 <address>
								<physical type="streetAddress">
									 <addressPart type="telephoneNumber">
										 <xsl:value-of select="normalize-space(.)"/>
									 </addressPart>
								</physical>
							 </address>
						 </location>
					 </xsl:for-each>
					 <xsl:for-each select="gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/gmd:facsimile/gco:CharacterString[string-length(text()) > 0]">
						 <location>
							 <address>
								<physical type="streetAddress">
									 <addressPart type="faxNumber">
										 <xsl:value-of select="normalize-space(.)"/>
									 </addressPart>
								</physical>
							 </address>
						 </location>
					 </xsl:for-each>
				</xsl:if>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>


	<xsl:template name="electronic">
		<xsl:for-each select="current-group()">
			<xsl:sort
				select="count(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gco:CharacterString[string-length(text()) > 0])"
				data-type="number" order="descending"/>

			<xsl:if test="position() = 1">
				<xsl:if test="count(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gco:CharacterString[string-length(text()) > 0])">
					<location>
						<address>
							<xsl:for-each select="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gco:CharacterString[string-length(text()) > 0]">
								<electronic type="email">
									<value>
										<xsl:value-of select="normalize-space(.)"/>
									</value>
								</electronic>
							</xsl:for-each>
						</address>
					</location>
				</xsl:if>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>


	<!-- Modules -->

	<xsl:template name="doiFromIdentifiers">
		<xsl:param name="identifier_sequence"/>
		<xsl:for-each select="distinct-values($identifier_sequence)">
			<xsl:if test="contains(lower-case(normalize-space(.)), 'doi')">
				<xsl:value-of select="normalize-space(.)"/>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>


	<xsl:template name="publishNameToUse">
		<xsl:message>Module: publishNameToUse</xsl:message>
		<xsl:variable name="organisationPublisherName">
			<xsl:call-template name="childValueForRole">
				<xsl:with-param name="roleSubstring">
					<xsl:text>publish</xsl:text>
				</xsl:with-param>
				<xsl:with-param name="childElementName">
					<xsl:text>organisationName</xsl:text>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<xsl:message>Organisation publisher name: <xsl:value-of select="$organisationPublisherName"></xsl:value-of></xsl:message>

		<xsl:variable name="transformedOrganisationPublisherName">
			<xsl:call-template name="transform">
				<xsl:with-param name="inputString" select="$organisationPublisherName"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="individualPublisherName">
			<xsl:call-template name="childValueForRole">
				<xsl:with-param name="roleSubstring">
					<xsl:text>publish</xsl:text>
				</xsl:with-param>
				<xsl:with-param name="childElementName">
					<xsl:text>individualName</xsl:text>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<xsl:message>Individual publisher name: <xsl:value-of select="$individualPublisherName"></xsl:value-of></xsl:message>

		<xsl:variable name="transformedIndividualPublisherName">
			<xsl:call-template name="transform">
				<xsl:with-param name="inputString" select="$individualPublisherName"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="string-length(normalize-space($transformedOrganisationPublisherName))">
				<xsl:value-of select="$transformedOrganisationPublisherName"/>
			</xsl:when>
			<xsl:when test="string-length(normalize-space($transformedIndividualPublisherName))">
				<xsl:value-of select="$transformedIndividualPublisherName"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$global_publisherName"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="publishPlaceToUse">
		<xsl:param name="publishNameToUse"/>
		<xsl:variable name="publishCity">
			<xsl:call-template name="childValueForRole">
				<xsl:with-param name="roleSubstring">
					<xsl:text>publish</xsl:text>
				</xsl:with-param>
				<xsl:with-param name="childElementName">
					<xsl:text>city</xsl:text>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<xsl:message>Publish City: <xsl:value-of select="$publishCity"/></xsl:message>

		<xsl:variable name="publishCountry">
			<xsl:call-template name="childValueForRole">
				<xsl:with-param name="roleSubstring">
					<xsl:text>publish</xsl:text>
				</xsl:with-param>
				<xsl:with-param name="childElementName">
					<xsl:text>country</xsl:text>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<xsl:message>Publish Country: <xsl:value-of select="$publishCountry"/></xsl:message>

		<xsl:choose>
			<xsl:when test="string-length($publishCity)">
				<xsl:value-of select="$publishCity"/>
			</xsl:when>
			<xsl:when test="string-length($publishCountry)">
				<xsl:value-of select="$publishCity"/>
			</xsl:when>
			<xsl:otherwise>
				<!-- Only default publisher place if publisher name is equal to the global value (whether it was set or retrieved) -->
				<xsl:if test="$publishNameToUse = $global_publisherName">
						<xsl:value-of select="$global_publisherPlace"></xsl:value-of>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="transform">
		<xsl:param name="inputString"/>
		<xsl:choose>
			<xsl:when test="normalize-space($inputString) = 'AADC'">
				<xsl:text>Australian Antarctic Data Centre</xsl:text>
			</xsl:when>
			<xsl:when test="normalize-space($inputString) = 'AAD'">
				<xsl:text>Australian Antarctic Division</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="normalize-space($inputString)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<!-- Get the values of the child element of the point of contact responsible parties whose role contains this substring provided
		 For example, if you provide roleSubsting as 'publish' and childElementName as 'organisationName',
			you will receive all organisation names within point of contact.  They will be separated by 'commas', with an 'and' between
			the last and second last, where applicable -->

	<xsl:template name="childValueForRole">
		<xsl:param name="roleSubstring"/>
		<xsl:param name="childElementName"/>
		<xsl:message>Child element name: <xsl:value-of select="$childElementName"></xsl:value-of></xsl:message>
		<xsl:variable name="nameSequence" as="xs:string*">
			<xsl:for-each-group
				select="descendant::gmd:CI_ResponsibleParty[
				(string-length(normalize-space(descendant::node()[local-name()=$childElementName]))) and
				(string-length(normalize-space(gmd:role/gmd:CI_RoleCode/@codeListValue)))]"
				group-by="descendant::node()[local-name()=$childElementName]">
				 <xsl:choose>
					<!-- obtain for two locations so far - we don't want for example we don't want
						responsible parties under citation of thesauruses used -->
					<xsl:when test="contains(local-name(..), 'pointOfContact') or
									contains(local-name(../../..), 'citation')">
						<!--xsl:message>Parent: <xsl:value-of select="ancestor::node()"></xsl:value-of></xsl:message-->
						<xsl:if test="contains(lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue), lower-case($roleSubstring))">
							<xsl:sequence select="descendant::node()[local-name()=$childElementName]"/>
							<xsl:message>Child value: <xsl:value-of select="descendant::node()[local-name()=$childElementName]"></xsl:value-of></xsl:message>
						</xsl:if>
					</xsl:when>
				</xsl:choose>
			 </xsl:for-each-group>
		</xsl:variable>
		<xsl:variable name="formattedValues">
			<xsl:for-each select="$nameSequence">
				<xsl:if test="position() > 1">
					<xsl:choose>
						<xsl:when test="position() = count($nameSequence)">
							<xsl:text> and </xsl:text>
						</xsl:when>
						<xsl:when test="position() &lt; count($nameSequence)">
							<xsl:text>, </xsl:text>
						</xsl:when>
					</xsl:choose>
				</xsl:if>
				<xsl:value-of select="."/>
			</xsl:for-each>
		</xsl:variable>
		<xsl:if test="string-length($formattedValues)">
			<xsl:message>Formatted values: <xsl:value-of select="$formattedValues"></xsl:value-of></xsl:message>
		</xsl:if>
		<xsl:value-of select="$formattedValues"/>
	</xsl:template>


	<xsl:template name="splitText_sequence" as="xs:string*">
		<xsl:param name="string"/>
		<xsl:param name="separator" select="', '"/>
		<xsl:choose>
			<xsl:when test="contains($string, $separator)">
				<xsl:if test="not(starts-with($string, $separator))">
					<xsl:value-of select="normalize-space(substring-before($string, $separator))"/>
				</xsl:if>
				<xsl:call-template name="splitText_sequence">
					<xsl:with-param name="string" select="normalize-space(substring-after($string,$separator))"/>
					<xsl:with-param name="separator" select="$separator"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="string-length(normalize-space($string))">
					<xsl:value-of select="normalize-space($string)"/>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
