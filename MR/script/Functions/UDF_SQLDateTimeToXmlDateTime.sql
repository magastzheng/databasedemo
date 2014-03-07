IF EXISTS (SELECT name FROM sysobjects WHERE name = 'UDF_SQLDateTimeToXmlDateTime' AND type = 'FN')
	DROP Function dbo.UDF_SQLDateTimeToXmlDateTime
GO

CREATE  FUNCTION dbo.UDF_SQLDateTimeToXmlDateTime (@DateTime DATETIME)
RETURNS VARCHAR(25)
AS
begin

declare @Return varchar(25)

/*
Replace datetime with a string containing the date and time formatted according to xsd:datetime
Eg: "1975-01-31T00:00:00"
*/

select @Return = convert(varchar(25), @DateTime, 126)

Return(@Return)

end


GO

