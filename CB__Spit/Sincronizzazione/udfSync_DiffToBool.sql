/* 
*
*	
*
*/
CREATE FUNCTION [udfSync_DiffToBool]
( 
	@sValue1 varchar(32),
    @sValue2 varchar(32)
)
RETURNS bit
AS
BEGIN
Declare @bResult bit
If LTrim(RTrim(IsNull(@sValue1, ''))) = '' And LTrim(RTrim(IsNull(@sValue1, ''))) <> LTrim(RTrim(IsNull(@sValue2, '')))
	Set @bResult = 1
Else
	Set @bResult = 0
RETURN @bResult
END