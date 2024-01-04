--!nocheck
-- Tests the accuracy of various color functions

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ColorScript = ReplicatedStorage.Color
local ColorTypes = require(ColorScript.ColorTypes)

---

local TOLERANCE = 1e-5

return function()
    describe("Conversions", function()
        it("xyY <-> XYZ should be accurate", function()
            local tests = {
                -- D65
                { xyz = {0, 0, 0}, xyy = {0.312727, 0.329023, 0} },
                { xyz = {0.950470, 1, 1.088830}, xyy = {0.312727, 0.329023, 1} },

                -- E
                { xyz = {1, 1, 1}, xyy = {1/3, 1/3, 1} },
                { xyz = {0.5, 0.5, 0.5}, xyy = {1/3, 1/3, 0.5} },
            }

            for i = 1, #tests do
                local test = tests[i]
                local X, Y, Z = test.xyz[1], test.xyz[2], test.xyz[3]
                local x, y, Y2 = test.xyy[1], test.xyy[2], test.xyy[3]

                local X_to_x, Y_to_y, XYZ_to_Y = ColorTypes.xyY.fromXYZ(X, Y, Z)
                expect(XYZ_to_Y).to.equal(Y)
                expect(X_to_x).to.be.near(x, TOLERANCE)
                expect(Y_to_y).to.be.near(y, TOLERANCE)

                local x_to_X, y_to_Y, xyY_to_Z = ColorTypes.xyY.toXYZ(x, y, Y2)
                expect(x_to_X).to.be.near(X, TOLERANCE)
                expect(y_to_Y).to.be.near(Y, TOLERANCE)
                expect(xyY_to_Z).to.be.near(Z, TOLERANCE)
            end
        end)

        it("Lab <-> XYZ should be accurate", function()
            -- TODO
        end)

        it("Lab <-> LCh(ab) should be accurate", function()
            -- TODO
        end)

        it("Luv <-> XYZ should be accurate", function()
            -- TODO
        end)

        it("Luv <-> LCh(uv) should be accurate", function()
            -- TODO
        end)

        it("LCh(uv) <-> HPLuv should be accurate", function()
            -- TODO
        end)

        it("LCh(uv) <-> HSLuv should be accurate", function()
            -- TODO
        end)

        it("XYZ <-> Oklab should be accurate", function()
            -- TODO
        end)

        --[[
        it("XYZ <-> Oklch should be accurate", function()
        end)
        ]]

        it("XYZ <-> sRGB should be accurate", function()
            TOLERANCE = 1e-4

            local tests = {
                { rgb = {0, 0, 0}, xyz = {0, 0, 0} },
                { rgb = {0.5, 0.5, 0.5}, xyz = {0.203440, 0.214041, 0.233054} },
                { rgb = {1, 1, 1}, xyz = {0.950470, 1, 1.088830} },

                { rgb = {1, 0, 0}, xyz = {0.412456, 0.212673, 0.019334} },
                { rgb = {0, 1, 0}, xyz = {0.357576, 0.715152, 0.119192} },
                { rgb = {0, 0, 1}, xyz = {0.180437, 0.072175, 0.950304} },

                { rgb = {0, 1, 1}, xyz = {0.538014, 0.787327, 1.069496} },
                { rgb = {1, 0, 1}, xyz = {0.592894, 0.284848, 0.969638} },
                { rgb = {1, 1, 0}, xyz = {0.770033, 0.927825, 0.138526} },
            }

            for i = 1, #tests do
                local test = tests[i]
                local r, g, b = test.rgb[1], test.rgb[2], test.rgb[3]
                local x, y, z = test.xyz[1], test.xyz[2], test.xyz[3]

                local rgb_to_x, rgb_to_y, rgb_to_z = ColorTypes.XYZ.fromRGB(r, g, b)
                expect(rgb_to_x).to.be.near(x, TOLERANCE)
                expect(rgb_to_y).to.be.near(y, TOLERANCE)
                expect(rgb_to_z).to.be.near(z, TOLERANCE)

                local xyz_to_r, xyz_to_g, xyz_to_b = ColorTypes.XYZ.toRGB(x, y, z)
                expect(xyz_to_r).to.be.near(r, TOLERANCE)
                expect(xyz_to_g).to.be.near(g, TOLERANCE)
                expect(xyz_to_b).to.be.near(b, TOLERANCE)
            end
        end)

        it("CMYK <-> sRGB should be accurate", function()
            local tests = {
                { rgb = {0, 0, 0}, cmyk = {0, 0, 0, 1} },
                { rgb = {0.5, 0.5, 0.5}, cmyk = {0, 0, 0, 0.5} },
                { rgb = {1, 1, 1}, cmyk = {0, 0, 0, 0} },

                { rgb = {1, 0, 0}, cmyk = {0, 1, 1, 0} },
                { rgb = {0, 1, 0}, cmyk = {1, 0, 1, 0} },
                { rgb = {0, 0, 1}, cmyk = {1, 1, 0, 0} },

                { rgb = {0, 1, 1}, cmyk = {1, 0, 0, 0} },
                { rgb = {1, 0, 1}, cmyk = {0, 1, 0, 0} },
                { rgb = {1, 1, 0}, cmyk = {0, 0, 1, 0} },

                { rgb = {0.2, 0.4, 0.8}, cmyk = {0.75, 0.5, 0, 0.2} },
            }

            for i = 1, #tests do
                local test = tests[i]
                local r, g, b = test.rgb[1], test.rgb[2], test.rgb[3]
                local c, m, y, k = test.cmyk[1], test.cmyk[2], test.cmyk[3], test.cmyk[4]

                local rgb_to_c, rgb_to_m, rgb_to_y, rgb_to_k = ColorTypes.CMYK.fromRGB(r, g, b)
                expect(rgb_to_c).to.be.near(c, TOLERANCE)
                expect(rgb_to_m).to.be.near(m, TOLERANCE)
                expect(rgb_to_y).to.be.near(y, TOLERANCE)
                expect(rgb_to_k).to.be.near(k, TOLERANCE)

                local cmyk_to_r, cmyk_to_g, cmyk_to_b = ColorTypes.CMYK.toRGB(c, m, y, k)
                expect(cmyk_to_r).to.be.near(r, TOLERANCE)
                expect(cmyk_to_g).to.be.near(g, TOLERANCE)
                expect(cmyk_to_b).to.be.near(b, TOLERANCE)
            end
        end)

        it("HSB <-> sRGB should be accurate", function()
            local tests = {
                { rgb = {0, 0, 0}, hsb = {0/0, 0, 0} },
                { rgb = {0.5, 0.5, 0.5}, hsb = {0/0, 0, 0.5} },
                { rgb = {1, 1, 1}, hsb = {0/0, 0, 1} },

                { rgb = {1, 0, 0}, hsb = {0, 1, 1} },
                { rgb = {0, 1, 0}, hsb = {120, 1, 1} },
                { rgb = {0, 0, 1}, hsb = {240, 1, 1} },

                { rgb = {0, 1, 1}, hsb = {180, 1, 1} },
                { rgb = {1, 0, 1}, hsb = {300, 1, 1} },
                { rgb = {1, 1, 0}, hsb = {60, 1, 1} },

                { rgb = {0.2, 0.4, 0.8}, hsb = {220, 0.75, 0.8} },
            }

            for i = 1, #tests do
                local test = tests[i]
                local r, g, b = test.rgb[1], test.rgb[2], test.rgb[3]
                local h, s, v = test.hsb[1], test.hsb[2], test.hsb[3]

                local rgb_to_h, rgb_to_s, rgb_to_v = ColorTypes.HSB.fromRGB(r, g, b)

                -- handle undefined hue
                if (h ~= h) then
                    expect(rgb_to_h).to.never.equal(h)
                    expect(rgb_to_s).to.equal(0)
                    expect(rgb_to_v).to.be.near(v, TOLERANCE)
                else
                    expect(rgb_to_h).to.be.near(h, TOLERANCE)
                    expect(rgb_to_s).to.be.near(s, TOLERANCE)
                    expect(rgb_to_v).to.be.near(v, TOLERANCE)
                end

                local hsv_to_r, hsv_to_g, hsv_to_b = ColorTypes.HSB.toRGB(h, s, v)
                expect(hsv_to_r).to.be.near(r, TOLERANCE)
                expect(hsv_to_g).to.be.near(g, TOLERANCE)
                expect(hsv_to_b).to.be.near(b, TOLERANCE)
            end
        end)

        it("HSL <-> HSB should be accurate", function()
            -- TODO
        end)

        it("HWB <-> HSB should be accurate", function()
            -- TODO
        end)
    end)

    describe("Functions", function()
        -- TODO
    end)
end