with Ada.Numerics.Generic_Elementary_Functions;
with Constant_Tables;

package body Image is

   package Float_Functions is new
     Ada.Numerics.Generic_Elementary_Functions (Float);
   use Float_Functions;

   ------------
   -- To_RGB --
   ------------

   function To_RGB (C : Bitmap_Color) return RGB_Float is
     (Float (C.Red),
      Float (C.Green),
      Float (C.Blue));

   ----------------
   -- RGB_To_HSV --
   ----------------

   function To_HSV (C : RGB_Float) return HSV_Color is
      Min, Max, D : Float;
      H, S, V : Float;
   begin
      Min := Float'Min (C.R, Float'Min (C.G, C.B));
      Max := Float'Max (C.R, Float'Max (C.G, C.B));

      V := Max;
      D := Max - Min;

      if Max /= 0.0 then
         S := D / Max;
      else
         S := 0.0;
         H := -1.0;
         return (H, S, V);
      end if;

      if Max = C.R then
         H := (C.G - C.B) / D;
      elsif Max = C.G then
         H := 2.0 + (C.B - C.R) / D;
      else
         H := 4.0 + (C.R - C.G) / D;
      end if;

      H := H * 60.0;

      if H < 0.0 then
         H := H + 360.0;
      end if;
      return (H, S, V);
   end To_HSV;


   ------------
   -- To_LAB --
   ------------

   function To_LAB (C : Bitmap_Color) return LAB_Color is
      --  Based on imlib.c from the OpenMV project
      --
      --  This file is part of the OpenMV project.
      --  Copyright (c) 2013/2014 Ibrahim Abdelkader <i.abdalkader@gmail.com>
      --  This work is licensed under the MIT license, see the file LICENSE
      --  for details.
      --
      R : constant Float := Constant_Tables.XYZ_Table (C.Red);
      G : constant Float := Constant_Tables.XYZ_Table (C.Green);
      B : constant Float := Constant_Tables.XYZ_Table (C.Blue);
      X : Float;
      Y : Float;
      Z : Float;
   begin

      X := ((R * 0.4124) + (G * 0.3576) + (B * 0.1805)) / 095.047;
      Y := ((R * 0.2126) + (G * 0.7152) + (B * 0.0722)) / 100.000;
      Z := ((R * 0.0193) + (G * 0.1192) + (B * 0.9505)) / 108.883;

      if X > 0.008856 then
         X := X ** (1.0 / 3.0);
      else
         X := X * 7.787037 + 0.137931;
      end if;
      if Y > 0.008856 then
         Y := Y ** (1.0 / 3.0);
      else
         Y := Y * 7.787037 + 0.137931;
      end if;
      if Z > 0.008856 then
         Z := Z ** (1.0 / 3.0);
      else
         Z := Z * 7.787037 + 0.137931;
      end if;

      return ((116.0 * Y) - 16.0,
              500.0 * (X - Y),
              200.0 * (Y - Z));
   end To_LAB;

   --------------
   -- Distance --
   --------------

   function Distance (C1, C2 : LAB_Color) return Float is
      A    : constant Float := (C1.L - C2.L) ** 2;
      B    : constant Float := (C1.A - C2.A) ** 2;
      C    : constant Float := (C1.B - C2.B) ** 2;
   begin
      return Sqrt (A + B + C);
   end Distance;

   --------------
   -- Distance --
   --------------

   function Distance (C1, C2 : Bitmap_Color) return Float is
   begin
      return Distance (To_LAB (C1), To_LAB (C2));
   end Distance;

end Image;
