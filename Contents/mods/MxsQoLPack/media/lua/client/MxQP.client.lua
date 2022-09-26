require "TimedActions/ISReadABook"

local old_ISReadABook_perform = ISReadABook.perform
function ISReadABook:perform(...)
    if self.item:getFullType() == "MxsQoLPack.NutritionistMag1" then
        if not self.character:HasTrait("Lucky") then
            self.character:getTraits():add("Nutritionist2");
        end
	end
	return old_ISReadABook_perform(self, ...)
end

