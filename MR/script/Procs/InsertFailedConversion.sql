IF EXISTS (SELECT name FROM sysobjects WHERE name = 'InsertFailedConversion' AND type = 'P')
	DROP Procedure dbo.InsertFailedConversion
GO

CREATE  PROCEDURE dbo.InsertFailedConversion @XmlDoc NVARCHAR(MAX), @UserID INT, @retval INT OUTPUT
AS

SET NOCOUNT ON
DECLARE @hXML INT

BEGIN TRY
	INSERT INTO FailedConversion WITH (rowlock)
		(UserID)
		SELECT  @UserID

	SELECT @retval = @@IDENTITY		-- save newly created ID

	-- insert investments
	EXEC sp_xml_preparedocument @hXML OUTPUT, @XmlDoc

	-- shred the xml into a temp table to avoid deadlocks when calculating the query plan
	DECLARE @Investment Table (SecID NVARCHAR(10), InvestmentName NVARCHAR(100), InvestmentType NVARCHAR(40), Reason NVARCHAR(100), InvestmentListName NVARCHAR(100))

	INSERT INTO @Investment (SecID, InvestmentName, InvestmentType, Reason, InvestmentListName)
	SELECT x.SecID, x.Name, x.Type, x.Reason, x.InvestmentList
	FROM OPENXML(@hXML, '//FailedConversionInvestment', 1)
	WITH (SecID NVARCHAR(10),
			Name NVARCHAR(100),
			Type NVARCHAR(40),
			Reason NVARCHAR(100),
			InvestmentList NVARCHAR(100)
	) x

	INSERT INTO FailedConversionInvestment WITH (rowlock)
		(FailedConversionID, SecID, InvestmentName, InvestmentType, Reason, InvestmentListName)
	SELECT @retval, inv.SecID, inv.InvestmentName, inv.InvestmentType, inv.Reason, inv.InvestmentListName
	FROM @Investment inv

	EXEC sp_xml_removedocument @hXML
END TRY
BEGIN CATCH
	IF @hXML IS NOT NULL 
	BEGIN	
		EXEC sp_xml_removedocument @hXML
	END
	
	EXEC Util_RethrowError;
END CATCH
SET NOCOUNT OFF
GO
