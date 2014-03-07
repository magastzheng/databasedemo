IF EXISTS (SELECT name FROM sysobjects WHERE name = 'ListFailedConversion' AND type = 'P')
	DROP Procedure dbo.ListFailedConversion
GO

CREATE  PROCEDURE dbo.ListFailedConversion
AS

SET NOCOUNT ON

SELECT *
FROM FailedConversionXMLView v
ORDER BY v.[@TimeCreated] DESC
FOR XML PATH('FailedConversion'), ROOT('FailedConversions')

SET NOCOUNT OFF
GO
