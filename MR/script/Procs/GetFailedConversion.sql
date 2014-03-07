IF EXISTS (SELECT name FROM sysobjects WHERE name = 'GetFailedConversion' AND type = 'P')
	DROP Procedure dbo.GetFailedConversion
GO

CREATE  PROCEDURE dbo.GetFailedConversion @FailedConversionID INT, @UserID INT
AS

SET NOCOUNT ON

SELECT *
FROM FailedConversionXMLView v
WHERE v.[@FailedConversionID] = @FailedConversionID AND v.[@UserID] = @UserID
FOR XML PATH('FailedConversion'), ROOT('FailedConversions')

SET NOCOUNT OFF
GO
