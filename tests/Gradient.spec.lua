local ColorModule = game:GetService("ReplicatedStorage").Color

return function()
    local Color = require(ColorModule.Color)
    local Gradient = require(ColorModule.Gradient)

    it("should be immutable", function()
        expect(function()
            Gradient.new = nil
        end).to.throw()
    end)

    it("should have a public API", function()
        expect(Gradient.new).to.be.a("function")
        expect(Gradient.fromColors).to.be.a("function")
        expect(Gradient.fromColorSequence).to.be.a("function")

        expect(Gradient.invert).to.be.a("function")
        expect(Gradient.color).to.be.a("function")
        expect(Gradient.colors).to.be.a("function")
        expect(Gradient.toColorSequence).to.be.a("function")
    end)

    describe("constructors", function()
        it("should enforce time constraints", function()
            expect(Gradient.new({
                {Time = 0, Color = Color.random()},
                {Time = 1, Color = Color.random()},
            })).to.be.ok()

            expect(function()
                Gradient.new({
                    {Time = 0, Color = Color.random()},
                    {Time = 1, Color = Color.random()},
                    {Time = 2, Color = Color.random()}
                })
            end).to.throw()
        end)

        it("should enforce sequential keypoint order", function()
            expect(Gradient.new({
                {Time = 0, Color = Color.random()},
                {Time = 0.5, Color = Color.random()},
                {Time = 1, Color = Color.random()},
            })).to.be.ok()

            expect(function()
                Gradient.new({
                    {Time = 0, Color = Color.random()},
                    {Time = 1, Color = Color.random()},
                    {Time = 0.5, Color = Color.random()}
                })
            end).to.throw()
        end)

        it("should support a keypoint array", function()
            local black = Color.new(0, 0, 0)
            local grey = Color.new(0.5, 0.5, 0.5)
            local white = Color.new(1, 1, 1)

            expect(function()
                Gradient.new({
                    {Time = 0, Color = black}
                })
            end).to.throw()

            expect(Gradient.new({
                {Time = 0, Color = black},
                {Time = 0.5, Color = grey},
                {Time = 1, Color = white}
            })).to.be.ok()
        end)

        it("should support one or more Colors", function()
            local black = Color.new(0, 0, 0)
            local grey = Color.new(0.5, 0.5, 0.5)
            local white = Color.new(1, 1, 1)

            expect(Gradient.fromColors(black)).to.be.ok()
            expect(Gradient.fromColors(black, white)).to.be.ok()
            expect(Gradient.fromColors(black, grey, white)).to.be.ok()

            expect(Gradient.fromColors(black)).to.equal(Gradient.new({
                {Time = 0, Color = black},
                {Time = 1, Color = black}
            }))

            expect(Gradient.fromColors(black, white)).to.equal(Gradient.new({
                {Time = 0, Color = black},
                {Time = 1, Color = white}
            }))

            expect(Gradient.fromColors(black, grey, white)).to.equal(Gradient.new({
                {Time = 0, Color = black},
                {Time = 0.5, Color = grey},
                {Time = 1, Color = white}
            }))
        end)

        it("should support a ColorSequence", function()
            local cs = ColorSequence.new(Color3.new(0, 0, 0), Color3.new(1, 1, 1))
            local black = Color.new(0, 0, 0)
            local white = Color.new(1, 1, 1)

            expect(Gradient.fromColorSequence(cs)).to.be.ok()

            expect(Gradient.fromColorSequence(cs)).to.equal(Gradient.new({
                {Time = 0, Color = black},
                {Time = 1, Color = white}
            }))
        end)
    end)

    describe("Gradients", function()
        it("should be immutable", function()
            local gradient = Gradient.fromColors(Color.new(0, 0, 0), Color.new(1, 1, 1))
            
            expect(function()
                gradient.Keypoints = nil
            end).to.throw()

            expect(function()
                gradient.Keypoints[-1] = true
            end).to.throw()
        end)

        it("should be invertible", function()
            local blackToWhite = Gradient.fromColors(Color.new(0, 0, 0), Color.new(1, 1, 1))
            local whiteToBlack = Gradient.fromColors(Color.new(1, 1, 1), Color.new(0, 0, 0))

            expect(blackToWhite).never.to.equal(whiteToBlack)
            expect(blackToWhite:invert()).to.equal(whiteToBlack)
            expect(whiteToBlack:invert()).to.equal(blackToWhite)
        end)

        it("should support generating colors", function()
            local gradient = Gradient.fromColors(Color.new(0, 0, 0), Color.new(1, 1, 1))

            expect(gradient:color(0.5)).to.be.ok()

            expect(function()
                gradient:color(-1)
            end).to.throw()

            expect(function()
                gradient:color(2)
            end).to.throw()

            expect(function()
                local numColors = 10
                local colors = gradient:colors(numColors)

                for i = 1, numColors do
                    assert(gradient:color((i - 1) / (numColors - 1)) == colors[i], "colors are not equidistant")
                end
            end).never.to.throw()
        end)

        it("should support generating ColorSequences", function()
            local gradient = Gradient.fromColors(Color.new(0, 0, 0), Color.new(1, 1, 1))

            expect(gradient:toColorSequence()).to.be.ok()
            expect(gradient:toColorSequence()).to.equal(ColorSequence.new(Color3.new(0, 0, 0), Color3.new(1, 1, 1)))
            expect(gradient:toColorSequence(nil, "lRGB")).never.to.equal(ColorSequence.new(Color3.new(0, 0, 0), Color3.new(1, 1, 1)))
        end)
    end)
end