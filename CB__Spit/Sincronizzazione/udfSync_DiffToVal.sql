/* 
*
*	
*
*/
CREATE FUNCTION [udfSync_DiffToVal]
( 
	@sValue1 varchar(2048),
    @sValue2 varchar(2048)
)
RETURNS varchar(2048)
AS
BEGIN
Declare @sResult varchar(2048)
If LTrim(RTrim(IsNull(@sValue1, ''))) = '' And LTrim(RTrim(IsNull(@sValue1, ''))) <> LTrim(RTrim(IsNull(@sValue2, '')))
	Set @sResult = @sValue2
Else
	Set @sResult = @sValue1
RETURN @sResult
END