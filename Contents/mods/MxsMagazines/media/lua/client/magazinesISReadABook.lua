require "TimedActions/ISReadABook"

local old_ISReadABook_perform = ISReadABook.perform
function ISReadABook:perform(...)
    if self.item:getFullType() == "MxQoLPack.NutritionistMag1" then
        if not self.character:HasTrait("Lucky") then
            self.character:getTraits():add("Nutritionist2");
            HaloTextHelper.addTextWithArrow(self.character, 'Nutritionist Trait', true, HaloTextHelper.getColorGreen())
        end
	end
	return old_ISReadABook_perform(self, ...)
end

