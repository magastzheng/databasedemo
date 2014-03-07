IF EXISTS (SELECT name FROM sysobjects WHERE name = 'GetLatestFailedConversion' AND type = 'P')
	DROP Procedure dbo.GetLatestFailedConversion
GO

CREATE  PROCEDURE dbo.GetLatestFailedConversion @UserID INT
AS

SET NOCOUNT ON

SELECT TOP 1 *
FROM FailedConversionXMLView v
WHERE v.[@UserID] = @UserID
ORDER BY v.[@TimeCreated] DESC
FOR XML PATH('FailedConversion')

SET NOCOUNT OFF
GO
