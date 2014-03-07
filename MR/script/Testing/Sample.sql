use MR

declare @retval int 
exec InsertFailedConversion '
<FailedConversion>
	<FailedConversionInvestments>
		<FailedConversionInvestment SecID="12345678" Name="ABC" Type="Stock" Reason="Fail" InvestmentList="MyList"/>
		<FailedConversionInvestment SecID="11111111" Name="XYZ" Type="Stock" Reason="Fail Worse" InvestmentList="MyOtherList"/>
	</FailedConversionInvestments>
</FailedConversion>
', 1, @retval output

print 'ID Inserted:'
print  @retval

exec ListFailedConversion

exec GetFailedConversion 2, 1

exec GetLatestFailedConversion 1
