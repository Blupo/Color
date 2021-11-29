local ColorModuleScript = game:GetService("ReplicatedStorage").Color
local ColorModule = require(ColorModuleScript)

return function()
    local Color = require(ColorModuleScript.Color)
    local Gradient = require(ColorModuleScript.Gradient)

    describe("Module", function()
        it("should mirror the Color API", function()
            expect(function()
                for key, callback in pairs(Color) do
                    assert(ColorModule[key] == callback, "Color." .. key .. " is missing")
                end
            end).never.to.throw()
        end)

        it("should include Gradient constructors", function()
            expect(ColorModule.gradient).to.equal(Gradient.new)
            expect(ColorModule.gradientFromColors).to.equal(Gradient.fromColors)
            expect(ColorModule.gradientFromColorSequence).to.equal(Gradient.fromColorSequence)
        end)
    end)
end