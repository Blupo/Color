return function()
    local Color = require(game:GetService("ReplicatedStorage").Color.Color)

    it("should be immutable", function()
        expect(function()
            Color.new = nil
        end).to.throw()
    end)

    it("should have a public API", function()
        expect(Color.new).to.be.a("function")
        expect(Color.random).to.be.a("function")
        expect(Color.gray).to.be.a("function")
        expect(Color.invert).to.be.a("function")
        expect(Color.components).to.be.a("function")
        expect(Color.deltaE).to.be.a("function")
        expect(Color.unclippedEq).to.be.a("function")
        expect(Color.isClipped).to.be.a("function")
        expect(Color.isAColor).to.be.a("function")
        expect(Color.luminance).to.be.a("function")
        expect(Color.contrast).to.be.a("function")
        expect(Color.bestContrastingColor).to.be.a("function")

        expect(Color.mix).to.be.a("function")
        expect(Color.blend).to.be.a("function")
        expect(Color.brighten).to.be.a("function")
        expect(Color.darken).to.be.a("function")
        expect(Color.saturate).to.be.a("function")
        expect(Color.desaturate).to.be.a("function")
        expect(Color.harmonies).to.be.a("function")

        expect(Color.from).to.be.a("function")
        expect(Color.to).to.be.a("function")
    end)

    it("should have alternative construction functions", function()
        expect(Color.fromBrickColor).to.be.a("function")
        expect(Color.fromCMYK).to.be.a("function")
        expect(Color.fromColor3).to.be.a("function")
        expect(Color.fromHex).to.be.a("function")
        expect(Color.fromHSB).to.be.a("function")
        expect(Color.fromHSL).to.be.a("function")
        expect(Color.fromHWB).to.be.a("function")
        expect(Color.fromLab).to.be.a("function")
        expect(Color.fromLChab).to.be.a("function")
        expect(Color.fromLChuv).to.be.a("function")
        expect(Color.fromLuv).to.be.a("function")
        expect(Color.fromNumber).to.be.a("function")
        expect(Color.fromRGB).to.be.a("function")
        expect(Color.fromTemperature).to.be.a("function")
        expect(Color.fromXYZ).to.be.a("function")

        expect(Color.fromHSV).to.equal(Color.fromHSB)
        expect(Color.fromLCh).to.equal(Color.fromLChab)
    end)

    it("should have alternative conversion functions", function()
        expect(Color.toBrickColor).to.be.a("function")
        expect(Color.toCMYK).to.be.a("function")
        expect(Color.toColor3).to.be.a("function")
        expect(Color.toHex).to.be.a("function")
        expect(Color.toHSB).to.be.a("function")
        expect(Color.toHSL).to.be.a("function")
        expect(Color.toHWB).to.be.a("function")
        expect(Color.toLab).to.be.a("function")
        expect(Color.toLChab).to.be.a("function")
        expect(Color.toLChuv).to.be.a("function")
        expect(Color.toLuv).to.be.a("function")
        expect(Color.toNumber).to.be.a("function")
        expect(Color.toRGB).to.be.a("function")
        expect(Color.toTemperature).to.be.a("function")
        expect(Color.toXYZ).to.be.a("function")

        expect(Color.toHSV).to.equal(Color.toHSB)
        expect(Color.toLCh).to.equal(Color.toLChab)
    end)

    it("should be able to identify non-Colors", function()
        local color = Color.new(0, 0, 0)

        local fakeColor = table.freeze({
            R = 0,
            G = 0,
            B = 0,

            __r = 0,
            __g = 0,
            __b = 0
        })

        expect(Color.isAColor(color)).to.equal(true)
        expect(Color.isAColor(fakeColor)).to.equal(false)
    end)

    describe("constructors", function()
        it("should support RGB", function()
            expect(Color.new(math.random(), math.random(), math.random())).to.be.ok()
            expect(Color.random()).to.be.ok()

            expect(Color.from("RGB", 123, 456, 789)).to.be.ok()
            expect(Color.from("RGB", 123, 456, 789)).never.to.equal(Color.new(123, 456, 789))

            expect(Color.gray(0.5)).to.equal(Color.new(0.5, 0.5, 0.5))
        end)

        it("should support Color3", function()
            expect(Color.from("Color3", Color3.new(math.random(), math.random(), math.random()))).to.be.ok()

            expect(function()
                Color.from("Color3", {
                    R = 1,
                    G = 1,
                    B = 1
                })
            end).to.throw()
        end)

        it("should support BrickColor", function()
            expect(Color.from("BrickColor", BrickColor.random())).to.be.ok()
            expect(Color.from("BrickColor", BrickColor.new(Color3.new(math.random(), math.random(), math.random())))).to.be.ok()
        end)

        it("should support hex codes", function()
            local aabbcc = Color.from("Hex", "aabbcc")
            local abc = Color.from("Hex", "abc")

            expect(aabbcc).to.equal(abc)
            expect(Color.from("Hex", "#abc")).to.equal(abc)

            expect(function()
                Color.from("Hex", "aabbccdd")
            end).to.throw("invalid hex length")

            expect(function()
                Color.from("Hex", "#xyz")
            end).to.throw("could not parse hex string")
        end)

        it("should support numeric values", function()
            expect(Color.from("Number", math.random(0, 256^3 - 1))).to.be.ok()

            expect(function()
                Color.from("Number", -1)
            end).to.throw()

            expect(function()
                Color.from("Number", 256^3)
            end).to.throw()

            expect(function()
                Color.from("Number", 0.5)
            end).to.throw()
        end)

        it("should support HSB/V", function()
            expect(Color.from("HSB", 0/0, 0, 0):to("Hex")).to.equal("000000")
            expect(Color.from("HSB", 0/0, 0, 1):to("Hex")).to.equal("ffffff")
            
            expect(Color.from("HSB", 0, 1, 1):to("Hex")).to.equal("ff0000")
            expect(Color.from("HSB", 120, 1, 1):to("Hex")).to.equal("00ff00")
            expect(Color.from("HSB", 240, 1, 1):to("Hex")).to.equal("0000ff")

            expect(Color.from("HSB", 60, 1, 1):to("Hex")).to.equal("ffff00")
            expect(Color.from("HSB", 300, 1, 1):to("Hex")).to.equal("ff00ff")
            expect(Color.from("HSB", 180, 1, 1):to("Hex")).to.equal("00ffff")

            expect(Color.new(0.5, 0.5, 0.5):to("HSB")).never.to.equal(0/0)
            expect(Color.from("HSV", 180, 1, 1)).to.equal(Color.from("HSB", 180, 1, 1))
        end)

        it("should support HSL", function()
            expect(Color.from("HSL", 0/0, 0, 0):to("Hex")).to.equal("000000")
            expect(Color.from("HSL", 0/0, 0, 1):to("Hex")).to.equal("ffffff")
            
            expect(Color.from("HSL", 0, 1, 0.5):to("Hex")).to.equal("ff0000")
            expect(Color.from("HSL", 120, 1, 0.5):to("Hex")).to.equal("00ff00")
            expect(Color.from("HSL", 240, 1, 0.5):to("Hex")).to.equal("0000ff")

            expect(Color.from("HSL", 60, 1, 0.5):to("Hex")).to.equal("ffff00")
            expect(Color.from("HSL", 300, 1, 0.5):to("Hex")).to.equal("ff00ff")
            expect(Color.from("HSL", 180, 1, 0.5):to("Hex")).to.equal("00ffff")

            expect(Color.new(0.5, 0.5, 0.5):to("HSL")).never.to.equal(0/0)
        end)

        it("should support HWB", function()
            expect(Color.from("HWB", 0/0, 0, 1):to("Hex")).to.equal("000000")
            expect(Color.from("HWB", 0/0, 1, 0):to("Hex")).to.equal("ffffff")
            
            expect(Color.from("HWB", 0, 0, 0):to("Hex")).to.equal("ff0000")
            expect(Color.from("HWB", 120, 0, 0):to("Hex")).to.equal("00ff00")
            expect(Color.from("HWB", 240, 0, 0):to("Hex")).to.equal("0000ff")

            expect(Color.from("HWB", 60, 0, 0):to("Hex")).to.equal("ffff00")
            expect(Color.from("HWB", 300, 0, 0):to("Hex")).to.equal("ff00ff")
            expect(Color.from("HWB", 180, 0, 0):to("Hex")).to.equal("00ffff")

            expect(Color.new(0.5, 0.5, 0.5):to("HWB")).never.to.equal(0/0)
        end)

        it("should support CMYK", function()
            expect(Color.from("CMYK", 0, 0, 0, 1):to("Hex")).to.equal("000000")
            expect(Color.from("CMYK", 0, 0, 0, 0):to("Hex")).to.equal("ffffff")
            
            expect(Color.from("CMYK", 0, 1, 1, 0):to("Hex")).to.equal("ff0000")
            expect(Color.from("CMYK", 1, 0, 1, 0):to("Hex")).to.equal("00ff00")
            expect(Color.from("CMYK", 1, 1, 0, 0):to("Hex")).to.equal("0000ff")

            expect(Color.from("CMYK", 0, 0, 1, 0):to("Hex")).to.equal("ffff00")
            expect(Color.from("CMYK", 0, 1, 0, 0):to("Hex")).to.equal("ff00ff")
            expect(Color.from("CMYK", 1, 0, 0, 0):to("Hex")).to.equal("00ffff")
        end)

        it("should support Kelvin", function()
            expect(Color.from("Temperature", 2000):to("Hex")).to.equal("ff8b00")
            expect(Color.from("Temperature", 3500):to("Hex")).to.equal("ffc38a")
            expect(Color.from("Temperature", 6500):to("Hex")).to.equal("fffafe")
        end)

        it("should support XYZ", function()
            expect(Color.from("XYZ", 0, 0, 0):to("Hex")).to.equal("000000")
            expect(Color.from("XYZ", 0.9504, 1, 1.0888):to("Hex")).to.equal("ffffff")

            expect(Color.from("XYZ", 0.41246, 0.21267, 0.01933):to("Hex")).to.equal("ff0000")
            expect(Color.from("XYZ", 0.35758, 0.71515, 0.11919):to("Hex")).to.equal("00ff00")
            expect(Color.from("XYZ", 0.18044, 0.07217, 0.95030):to("Hex")).to.equal("0000ff")

            expect(Color.from("XYZ", 0.77003, 0.92783, 0.13853):to("Hex")).to.equal("ffff00")
            expect(Color.from("XYZ", 0.59289, 0.28485, 0.96964):to("Hex")).to.equal("ff00ff")
            expect(Color.from("XYZ", 0.53801, 0.78733, 1.06950):to("Hex")).to.equal("00ffff")
        end)

        it("should support L*a*b*", function()
            expect(Color.from("Lab", 0, 0, 0):to("Hex")).to.equal("000000")
            expect(Color.from("Lab", 1, 0, 0):to("Hex")).to.equal("ffffff")

            expect(Color.from("Lab", 0.53241, 0.80092, 0.67203):to("Hex")).to.equal("ff0000")
            expect(Color.from("Lab", 0.87735, -0.86183, 0.83179):to("Hex")).to.equal("00ff00")
            expect(Color.from("Lab", 0.32297, 0.79188, -1.07860):to("Hex")).to.equal("0000ff")

            expect(Color.from("Lab", 0.97139, -0.21554, 0.94478):to("Hex")).to.equal("ffff00")
            expect(Color.from("Lab", 0.60324, 0.98234, -0.60825):to("Hex")).to.equal("ff00ff")
            expect(Color.from("Lab", 0.91113, -0.48088, -0.14131):to("Hex")).to.equal("00ffff")
        end)

        it("should support L*C*h(ab)", function()
            expect(Color.from("LChab", 0, 0, 0):to("Hex")).to.equal("000000")
            expect(Color.from("LChab", 1, 0, 0):to("Hex")).to.equal("ffffff")

            expect(Color.from("LChab", 0.53241, 1.04552, 39.999):to("Hex")).to.equal("ff0000")
            expect(Color.from("LChab", 0.87735, 1.19776, 136.016):to("Hex")).to.equal("00ff00")
            expect(Color.from("LChab", 0.32297, 1.33808, 306.285):to("Hex")).to.equal("0000ff")

            expect(Color.from("LChab", 0.97139, 0.96905, 102.851):to("Hex")).to.equal("ffff00")
            expect(Color.from("LChab", 0.60324, 1.15541, 328.235):to("Hex")).to.equal("ff00ff")
            expect(Color.from("LChab", 0.91113, 0.50121, 196.376):to("Hex")).to.equal("00ffff")

            expect(Color.from("LCh", 0.91113, 0.50121, 196.376)).to.equal(Color.from("LChab", 0.91113, 0.50121, 196.376))
        end)

        it("should support L*u*v*", function()
            expect(Color.from("Luv", 0, 0, 0):to("Hex")).to.equal("000000")
            expect(Color.from("Luv", 1, 0, 0):to("Hex")).to.equal("ffffff")

            expect(Color.from("Luv", 0.53241, 1.75015, 0.37756):to("Hex")).to.equal("ff0000")
            expect(Color.from("Luv", 0.87735, -0.83078, 1.07399):to("Hex")).to.equal("00ff00")
            expect(Color.from("Luv", 0.32297, -0.09405, -1.30342):to("Hex")).to.equal("0000ff")

            expect(Color.from("Luv", 0.97139, 0.07706, 1.06787):to("Hex")).to.equal("ffff00")
            expect(Color.from("Luv", 0.60324, 0.84071, -1.08683):to("Hex")).to.equal("ff00ff")
            expect(Color.from("Luv", 0.91113, -0.70477, -0.15204):to("Hex")).to.equal("00ffff")
        end)

        it("should support L*C*h(uv)", function()
            expect(Color.from("LChuv", 0, 0, 0):to("Hex")).to.equal("000000")
            expect(Color.from("LChuv", 1, 0, 0):to("Hex")).to.equal("ffffff")

            expect(Color.from("LChuv", 0.53241, 1.79041, 12.174):to("Hex")).to.equal("ff0000")
            expect(Color.from("LChuv", 0.87735, 1.35780, 127.724):to("Hex")).to.equal("00ff00")
            expect(Color.from("LChuv", 0.32297, 1.30681, 265.873):to("Hex")).to.equal("0000ff")

            expect(Color.from("LChuv", 0.97139, 1.07064, 85.873):to("Hex")).to.equal("ffff00")
            expect(Color.from("LChuv", 0.60324, 1.37405, 307.724):to("Hex")).to.equal("ff00ff")
            expect(Color.from("LChuv", 0.91113, 0.72099, 192.174):to("Hex")).to.equal("00ffff")
        end)

        it("should not support invalid color types", function()
            expect(function()
                Color.from("InvalidColorType", 1, "A", "F")
            end).to.throw("invalid color type")
        end)
    end)

    describe("Colors", function()
        it("should be immutable", function()
            local color = Color.new(1, 1, 1)

            expect(function()
                color.R = nil
            end).to.throw()

            expect(function()
                setmetatable(color, nil)
            end).to.throw()
        end)

        it("should support equality", function()
            local color1 = Color.new(1, 1, 1)
            local color2 = Color.new(1, 1, 1)
            local color3 = Color.new(0, 0, 0)
            local color4 = Color.new(2, 2, 2)

            expect(color1 == color1).to.equal(true)
            expect(color1 == color2).to.equal(true)
            expect(color1 == color3).to.equal(false)
            expect(color1 == color4).to.equal(true)
        end)

        it("should support operations", function()
            local color1 = Color.random()
            local color2 = Color.new(1, 1, 1)
            local color3 = Color.new(2, 2, 2)
            local color1Components = { color1:components() }

            expect(color1:invert()).to.be.ok()
            expect(color2:unclippedEq(color3)).to.equal(false)
            expect(color3:isClipped()).to.equal(true)

            expect(color1Components[1]).to.equal(color1.R)
            expect(color1Components[2]).to.equal(color1.G)
            expect(color1Components[3]).to.equal(color1.B)
        end)

        it("should support luminance and contrast calculations", function()
            local black = Color.new(0, 0, 0)
            local white = Color.new(1, 1, 1)
            local red = Color.new(1, 0, 0)
            local blue = Color.new(0, 0, 1)

            expect(black:contrast(white)).to.equal(21)
            expect(white:contrast(black)).to.equal(21)
            expect(black:contrast(black)).to.equal(1)
            expect(white:contrast(white)).to.equal(1)

            expect(black:contrast(red)).to.be.near(5.25, 10^-2)
            expect(black:contrast(blue)).to.be.near(2.44, 10^-2)
            expect(white:contrast(red)).to.be.near(4, 10^-2)
            expect(white:contrast(blue)).to.be.near(8.6, 10^-2)
            expect(red:contrast(blue)).to.be.near(2.14, 10^-2)

            expect(white:bestContrastingColor(black, red, blue)).to.equal(black)

            expect(function()
                white:bestContrastingColor()
            end).to.throw("no colors to compare")
        end)

        it("should support conversions", function()
            local hotpink = Color.from("Hex", "ff69b4")

            local brickColor = hotpink:to("BrickColor")
            local color3 = hotpink:to("Color3")

            local hex = hotpink:to("Hex")
            local number = hotpink:to("Number")
            local temperature = hotpink:to("Temperature")

            local rRGB, gRGB, bRGB = hotpink:to("RGB")
            local hHSB, sHSB, bHSB = hotpink:to("HSB")
            local hHSL, sHSL, lHSL = hotpink:to("HSL")
            local cCMYK, mCMYK, yCMYK, kCMYK = hotpink:to("CMYK")
            local xXYZ, yXYZ, zXYZ = hotpink:to("XYZ")
            local lLab, aLab, bLab = hotpink:to("Lab")
            local lLuv, uLuv, vLuv = hotpink:to("Luv")
            local lLChab, cLChab, hLChab = hotpink:to("LChab")
            local lLChuv, cLChuv, hLChuv = hotpink:to("LChuv")

            expect(brickColor).to.equal(BrickColor.new("Pink"))
            expect(color3).to.equal(Color3.fromRGB(255, 105, 180))

            expect(hex).to.equal("ff69b4")
            expect(number).to.equal(16738740)
            expect(temperature).to.equal(4358)

            expect(rRGB).to.equal(255)
            expect(gRGB).to.equal(105)
            expect(bRGB).to.equal(180)

            expect(hHSB).to.equal(330)
            expect(sHSB).to.be.near(0.58824, 10^-4)
            expect(bHSB).to.equal(1)

            expect(hHSL).to.equal(330)
            expect(sHSL).to.equal(1)
            expect(lHSL).to.be.near(0.70588, 10^-4)

            expect(cCMYK).to.equal(0)
            expect(mCMYK).to.be.near(0.58824, 10^-4)
            expect(yCMYK).to.be.near(0.29412, 10^-4)
            expect(kCMYK).to.equal(0)

            expect(xXYZ).to.be.near(0.54532, 10^-4)
            expect(yXYZ).to.be.near(0.34664, 10^-4)
            expect(zXYZ).to.be.near(0.46990, 10^-4)

            expect(lLab).to.be.near(0.65486, 10^-4)
            expect(aLab).to.be.near(0.64238, 10^-4)
            expect(bLab).to.be.near(-0.10646, 10^-4)

            expect(lLuv).to.be.near(0.65486, 10^-4)
            expect(uLuv).to.be.near(0.91125, 10^-4)
            expect(vLuv).to.be.near(-0.27488, 10^-4)

            expect(lLChab).to.be.near(0.65486, 10^-4)
            expect(cLChab).to.be.near(0.65115, 10^-4)
            expect(hLChab).to.be.near(350.590, 10^-1)

            expect(lLChuv).to.be.near(0.65486, 10^-4)
            expect(cLChuv).to.be.near(0.95180, 10^-4)
            expect(hLChuv).to.be.near(343.214, 10^-1)

            expect(hHSL).to.equal(hHSB)
            expect(lLuv).to.equal(lLab)
            expect(lLChab).to.equal(lLab)
            expect(lLChuv).to.equal(lLab)

            expect(function()
                hotpink:to("InvalidColorType")
            end).to.throw("invalid color type")
        end)

        it("should support blending", function()
            -- TODO: verify testing outputs
            local color1 = Color.from("Hex", "4cbbfc")
            local color2 = Color.from("Hex", "eeee22")

            expect(color1:blend(color2, "Normal"):to("Hex")).to.equal("eeee22")
            expect(color1:blend(color2, "Multiply"):to("Hex")).to.equal("47af22")
            expect(color1:blend(color2, "Screen"):to("Hex")).to.equal("f3fafc")
            expect(color1:blend(color2, "Overlay"):to("Hex")).to.equal("8ef6fa")
            expect(color1:blend(color2, "Darken"):to("Hex")).to.equal("4cbb22")
            expect(color1:blend(color2, "Lighten"):to("Hex")).to.equal("eeeefc")
            expect(color1:blend(color2, "ColorDodge"):to("Hex")).to.equal("ffffff")
            expect(color1:blend(color2, "ColorBurn"):to("Hex")).to.equal("3fb6e9")
            expect(color1:blend(color2, "HardLight"):to("Hex")).to.equal("e7f643")
            expect(color1:blend(color2, "SoftLight"):to("Hex")).to.equal("83d6fa")
            expect(color1:blend(color2, "Difference"):to("Hex")).to.equal("a233da")
            expect(color1:blend(color2, "Exclusion"):to("Hex")).to.equal("ac4cdb")

            expect(function()
                color1:blend(color2, "InvalidBlendType")
            end).to.throw("invalid blend mode")
        end)

        it("should support L*a*b* operations", function()
            local hotpink = Color.from("Hex", "ff69b4")
            local slategray = Color.from("Hex", "708090")

            expect(hotpink:darken():to("Hex")).to.equal("c93384")
            expect(hotpink:darken(2):to("Hex")).to.equal("930058")
            expect(hotpink:darken(2.6):to("Hex")).to.equal("74003f")

            expect(hotpink:brighten():to("Hex")).to.equal("ff9ce6")
            expect(hotpink:brighten(2):to("Hex")).to.equal("ffd1ff")
            expect(hotpink:brighten(3):to("Hex")).to.equal("ffffff")

            expect(slategray:saturate():to("Hex")).to.equal("4b83ae")
            expect(slategray:saturate(2):to("Hex")).to.equal("0087cd")
            expect(slategray:saturate(3):to("Hex")).to.equal("008bec")

            expect(hotpink:desaturate():to("Hex")).to.equal("e77dae")
            expect(hotpink:desaturate(2):to("Hex")).to.equal("cd8ca8")
            expect(hotpink:desaturate(3):to("Hex")).to.equal("b199a3")
        end)

        it("should support harmony generation", function()
            local red = Color.new(1, 0, 0)

            local complementary = red:harmonies("Complementary")
            local triadic = red:harmonies("Triadic")
            local square = red:harmonies("Square")

            local analogous = red:harmonies("Analogous")
            local splitComplementary = red:harmonies("SplitComplementary")
            local tetradic = red:harmonies("Tetradic")

            expect(complementary[1]:to("Hex")).to.equal("00ffff")

            expect(triadic[1]:to("Hex")).to.equal("00ff00")
            expect(triadic[2]:to("Hex")).to.equal("0000ff")

            expect(square[1]:to("Hex")).to.equal("80ff00")
            expect(square[2]:to("Hex")).to.equal("00ffff")
            expect(square[3]:to("Hex")).to.equal("8000ff")

            expect(analogous[1]:to("Hex")).to.equal("ff0080")
            expect(analogous[2]:to("Hex")).to.equal("ff8000")

            expect(splitComplementary[1]:to("Hex")).to.equal("00ff80")
            expect(splitComplementary[2]:to("Hex")).to.equal("0080ff")

            expect(tetradic[1]:to("Hex")).to.equal("ff8000")
            expect(tetradic[2]:to("Hex")).to.equal("00ffff")
            expect(tetradic[3]:to("Hex")).to.equal("0080ff")

            expect(function()
                red:harmonies("InvalidHarmony")
            end).to.throw()
        end)

        it("should support ΔE* calculation", function()
            -- Test data from: http://www2.ece.rochester.edu/~gsharma/ciede2000/ciede2000noteCRNA.pdf

            local tests = {
                { Color.fromLab(0.5, 0.026772, -0.797751), Color.fromLab(0.5, 0, -0.827485), 2.0425 },
                { Color.fromLab(0.5, 0.031571, -0.772803), Color.fromLab(0.5, 0, -0.827485), 2.8615 },
                { Color.fromLab(0.5, 0.028361, -0.740200), Color.fromLab(0.5, 0, -0.827485), 3.4412 },
                { Color.fromLab(0.5, -0.013802, -0.842814), Color.fromLab(0.5, 0, -0.827485), 1 },
                { Color.fromLab(0.5, -0.011848, -0.848006), Color.fromLab(0.5, 0, -0.827485), 1 },
                { Color.fromLab(0.5, -0.009009, -0.855211), Color.fromLab(0.5, 0, -0.827485), 1 },
                { Color.fromLab(0.5, 0, 0), Color.fromLab(0.5, -0.01, 0.02), 2.3669 },
                { Color.fromLab(0.5, -0.01, 0.02), Color.fromLab(0.5, 0, 0), 2.3669 },
                { Color.fromLab(0.5, 0.0249, -0.00001), Color.fromLab(0.5, -0.0249, 0.000009), 7.1792 },
                { Color.fromLab(0.5, 0.0249, -0.00001), Color.fromLab(0.5, -0.0249, 0.00001), 7.1792 },
                { Color.fromLab(0.5, 0.0249, -0.00001), Color.fromLab(0.5, -0.0249, 0.000011), 7.2195 },
                { Color.fromLab(0.5, 0.0249, -0.00001), Color.fromLab(0.5, -0.0249, 0.000012), 7.2195 },
                { Color.fromLab(0.5, -0.00001, 0.0249), Color.fromLab(0.5, 0.000009, -0.0249), 4.8045 },
                { Color.fromLab(0.5, -0.00001, 0.0249), Color.fromLab(0.5, 0.00001, -0.0249), 4.8045 },
                { Color.fromLab(0.5, -0.00001, 0.0249), Color.fromLab(0.5, 0.000011, -0.0249), 4.7461 },
                { Color.fromLab(0.5, 0.025, 0), Color.fromLab(0.5, 0, -0.025), 4.3065 },
                { Color.fromLab(0.5, 0.025, 0), Color.fromLab(0.73, 0.25, -0.18), 27.1492 },
                { Color.fromLab(0.5, 0.025, 0), Color.fromLab(0.61, -0.05, 0.29), 22.8977 },
                { Color.fromLab(0.5, 0.025, 0), Color.fromLab(0.56, -0.27, -0.03), 31.9030 },
                { Color.fromLab(0.5, 0.025, 0), Color.fromLab(0.58, 0.24, 0.15), 19.4535 },
                { Color.fromLab(0.5, 0.025, 0), Color.fromLab(0.5, 0.031736, 0.005854), 1 },
                { Color.fromLab(0.5, 0.025, 0), Color.fromLab(0.5, 0.032972, 0), 1 },
                { Color.fromLab(0.5, 0.025, 0), Color.fromLab(0.5, 0.018634, 0.005757), 1 },
                { Color.fromLab(0.5, 0.025, 0.), Color.fromLab(0.5, 0.032592, 0.003350), 1 },
                { Color.fromLab(0.602574, -0.340099, 0.362677), Color.fromLab(0.604626, -0.341751, 0.394387), 1.2644 },
                { Color.fromLab(0.630109, -0.310961, -0.058663), Color.fromLab(0.628187, -0.297946, -0.040864), 1.2630 },
                { Color.fromLab(0.612901, 0.037196, -0.053901), Color.fromLab(0.614292, 0.022480, -0.049620), 1.8731 },
                { Color.fromLab(0.350831, -0.441164, 0.037933), Color.fromLab(0.350232, -0.400716, 0.015901), 1.8645 },
                { Color.fromLab(0.227233, 0.200904, -0.466940), Color.fromLab(0.230331, 0.149730, -0.425619), 2.0373 },
                { Color.fromLab(0.364612, 0.478580, 0.183852), Color.fromLab(0.362715, 0.505065, 0.212231), 1.4146 },
                { Color.fromLab(0.908027, -0.020831, 0.014410), Color.fromLab(0.911528, -0.016435, 0.000447), 1.4441 },
                { Color.fromLab(0.909257, -0.005406, -0.009208), Color.fromLab(0.886381, -0.008985, -0.007239), 1.5381 },
                { Color.fromLab(0.067747, -0.002908, -0.024247), Color.fromLab(0.058714, -0.000985, -0.022286), 0.6377 },
                { Color.fromLab(0.020776, 0.000795, -0.011350), Color.fromLab(0.009033, -0.000636, -0.005514), 0.9082 },
            }

            for i = 1, #tests do
                local test = tests[i]

                local testColor1, testColor2 = test[1], test[2]
                local expectedResult = test[3]

                expect(testColor1:deltaE(testColor2)).to.be.near(expectedResult, 10^-4)
                expect(testColor2:deltaE(testColor1)).to.be.near(expectedResult, 10^-4)
            end
        end)

        it("should support interpolation", function()
            local red = Color.new(1, 0, 0)
            local blue = Color.new(0, 0, 1)

            expect(red:mix(blue, 0.5, "RGB"):to("Hex")).to.equal("800080")
            expect(red:mix(blue, 0.5, "HSB"):to("Hex")).to.equal("ff00ff")
            expect(red:mix(blue, 0.5, "HSL"):to("Hex")).to.equal("ff00ff")
            expect(red:mix(blue, 0.5, "HWB"):to("Hex")).to.equal("ff00ff")
            expect(red:mix(blue, 0.5, "Lab"):to("Hex")).to.equal("ca0088")
            expect(red:mix(blue, 0.5, "LChab"):to("Hex")).to.equal("fa0080")
            expect(red:mix(blue, 0.5, "Luv"):to("Hex")).to.equal("be0090")
            expect(red:mix(blue, 0.5, "LChuv"):to("Hex")).to.equal("f000cc")
            expect(red:mix(blue, 0.5, "lRGB"):to("Hex")).to.equal("bc00bc")
            expect(red:mix(blue, 0.5, "XYZ"):to("Hex")).to.equal("bc00bc")

            expect(red:mix(blue, 0.5, "HSB", "Shorter"):to("Hex")).never.to.equal(red:mix(blue, 0.5, "HSB", "Longer"))
            expect(red:mix(blue, 0.5, "HSB", "Increasing"):to("Hex")).never.to.equal(red:mix(blue, 0.5, "HSB", "Decreasing"))
            expect(red:mix(blue, 0.5, "HSB", "Raw")).to.be.ok()

            expect(red:mix(blue, 0.5, "HSV")).to.equal(red:mix(blue, 0.5, "HSB"))
            expect(red:mix(blue, 0.5, "LCh")).to.equal(red:mix(blue, 0.5, "LChab"))

            expect(function()
                red:mix(blue, 0.5, "InvalidInterpolation")
            end).to.throw("invalid interpolator")

            expect(function()
                red:mix(blue, 0.5, "HSB", "InvalidHueAdjustment")
            end).to.throw("invalid hue adjustment")
        end)
    end)
end