IF EXISTS (SELECT name FROM sysobjects WHERE name = 'FailedConversionXMLView' AND type = 'V')
	DROP VIEW dbo.FailedConversionXMLView
GO

CREATE VIEW dbo.FailedConversionXMLView
AS
	SELECT FailedConversion.FailedConversionID AS '@FailedConversionID',
			FailedConversion.UserID AS '@UserID',
			dbo.UDF_SQLDateTimeToXmlDateTime(FailedConversion.TimeCreated) AS '@TimeCreated',
			(
				SELECT SecID AS '@SecID',
						InvestmentName AS '@Name',
						InvestmentType AS '@Type',
						Reason AS '@Reason',
						InvestmentListName AS '@ListName'
				FROM FailedConversionInvestment WITH (readcommitted)
				WHERE FailedConversion.FailedConversionID = FailedConversionInvestment.FailedConversionID
				FOR XML PATH('FailedConversionInvestment'), TYPE
			) as 'FailedConversionInvestments'
	FROM FailedConversion WITH (readcommitted)
	
GO
