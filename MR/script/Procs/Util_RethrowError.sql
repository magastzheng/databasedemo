IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Util_RethrowError' AND type = 'P')
	DROP PROCEDURE dbo.Util_RethrowError
GO

--Based on -
--MSDN: Using Try...Catch in Transact-SQL
--http://msdn.microsoft.com/en-us/library/ms179296.aspx
CREATE PROCEDURE dbo.Util_RethrowError
AS
SET NOCOUNT ON
	
	IF ERROR_NUMBER() IS NULL
		RETURN;

	DECLARE
		@ErrorMessage		NVARCHAR(4000),
		@ErrorNumber		INT,
		@ErrorSeverity		INT,
		@ErrorState			INT,
		@ErrorLine			INT,
		@ErrorProcedure		NVARCHAR(200);

	SELECT
		@ErrorNumber		= ERROR_NUMBER(),
		@ErrorSeverity		= ERROR_SEVERITY(),
		@ErrorState			= ERROR_STATE(),
		@ErrorLine			= ERROR_LINE(),
		@ErrorProcedure		= ISNULL(ERROR_PROCEDURE(), '-');

	--Error Message Format String used by RAISERROR
	SELECT
		@ErrorMessage = 
			'Error %d, Level %d, State %d, Procedure %s, Line %d, ' +
				'Message: ' + ERROR_MESSAGE();


	RAISERROR( 	@ErrorMessage,			-- Error Message to raise, matching original
				@ErrorSeverity,			-- Error Severity to raise, matching original
				1,						-- Error State = 1, User Thrown
				@ErrorNumber,			-- parameters for original error message to be formatted in @ErrorMessage
				@ErrorSeverity,
				@ErrorState,
				@ErrorProcedure,
				@ErrorLine);

SET NOCOUNT OFF

GO