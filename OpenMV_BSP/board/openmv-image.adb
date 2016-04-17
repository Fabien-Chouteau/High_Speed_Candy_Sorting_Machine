with Interfaces;           use Interfaces;
with Interfaces.Bit_Types; use Interfaces.Bit_Types;
with Ada.Numerics.Generic_Elementary_Functions;
with OpenMV.Constant_Tables;

package body OpenMV.Image is

   package Float_Functions is new
     Ada.Numerics.Generic_Elementary_Functions (Float);
   use Float_Functions;

   function To_Short (C : Color) return Short with Inline_Always;
   function To_RGB (Raw : Short) return Color with Inline_Always;
   function To_RGB (Raw : Short) return RGB_Float with Inline_Always;
   function Byte_Swap (Raw : Short) return Short with Inline_Always;

   --------------
   -- To_Short --
   --------------

   function To_Short (C : Color) return Short is
      R, G, B : Short;
   begin
      R := Shift_Right (Short (C.R), 3);
      R := Shift_Left (R and 16#1F#, 11);

      G := Shift_Right (Short (C.G), 2);
      G := Shift_Left (G and 16#3F#, 5);

      B := Shift_Right (Short (C.B), 3) and 16#1F#;
      return Byte_Swap (R or G or B);
   end To_Short;

   ------------
   -- To_RGB --
   ------------

   function To_RGB (Raw : Short) return Color is
      R, G, B : RGB_Component;
      Tmp : constant Short := Byte_Swap (Raw);
   begin

      R := RGB_Component (Shift_Left (Shift_Right (Tmp, 11) and 16#1F#, 3));
      G := RGB_Component (Shift_Left (Shift_Right (Tmp, 5) and 16#3F#, 2));
      B := RGB_Component (Shift_Left (Tmp and 16#1F#, 3));

      return (R, G, B);
   end To_RGB;

   function To_RGB (Raw : Short) return RGB_Float is
      (To_RGB (To_RGB (Raw)));

   ----------------
   -- Byte_Shift --
   ----------------

   function Byte_Swap (Raw : Short) return Short is
     (Shift_Left (Raw and 16#FF#, 8) or Shift_Right (Raw and 16#FF00#, 8));

   ----------
   -- Fill --
   ----------

   procedure Fill (C : Color) is
      Raw : constant Short := To_Short (C);
   begin
      for Elt of FB.Data.all loop
         Elt := Raw;
      end loop;
   end Fill;

   ---------------
   -- Set_Pixel --
   ---------------

   procedure Set_Pixel (X : Width; Y : Height; C : Color) is
   begin
      FB.Data (X + Y * Image_Width) := To_Short (C);
   end Set_Pixel;

   ------------
   -- To_RGB --
   ------------

   function To_RGB (C : Color) return RGB_Float is
     (Float (C.R),
      Float (C.G),
      Float (C.B));

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

   function To_LAB (C : Color) return LAB_Color is
      --  Based on imlib.c from the OpenMV project
      --
      --  This file is part of the OpenMV project.
      --  Copyright (c) 2013/2014 Ibrahim Abdelkader <i.abdalkader@gmail.com>
      --  This work is licensed under the MIT license, see the file LICENSE
      --  for details.
      --
      R : constant Float := Constant_Tables.XYZ_Table (C.R);
      G : constant Float := Constant_Tables.XYZ_Table (C.G);
      B : constant Float := Constant_Tables.XYZ_Table (C.B);
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
--        return (A + B + C);
   end Distance;

   --------------
   -- Distance --
   --------------

   function Distance (C1, C2 : Color) return Float is
   begin
      return Distance (To_LAB (C1), To_LAB (C2));
   end Distance;

   ----------
   -- Test --
   ----------
   type Ref_Color is record
      C   : Color;
      Lab : LAB_Color;
   end record;

   type Ref_Color_Array is array (Candy_Colors) of Ref_Color;
   Ref_Colors : constant Ref_Color_Array :=
     ((Red,         To_LAB (Red)),
      (Orange,      To_LAB (Orange)),
      (Yellow,      To_LAB (Yellow)),
      (Lime_Green,  To_LAB (Lime_Green)),
      (Medium_Blue, To_LAB (Medium_Blue)),
      (Black,       To_LAB (Black)),
      (White,       To_LAB (White))
     );

   procedure Test is
      Lab       : LAB_Color;
      Dist      : Float;
      Min_Dist  : Float;
      New_Color : Candy_Colors;
      Cnt       : Natural := 0;
      Color_Cnt : array (Candy_Colors) of Natural := (others => 0);
   begin

      --  Display a line of each reference color
      for Ref of Ref_Colors loop
         for X in Cnt * 5 .. (Cnt + 1) * 5 - 1 loop
            for Y in Height'Range loop
               Set_Pixel (X, Y, Ref.C);
            end loop;
         end loop;
         Cnt := Cnt + 1;
      end loop;

      --  Seach for reference colors
      for Index in FB.Data.all'First .. FB.Data.all'Last loop
         Lab := To_LAB (To_RGB (FB.Data.all (Index)));
         New_Color := Candy_White;
         Min_Dist := Float'Last;
         for Ref in Candy_Colors loop
            Dist := Distance (Lab, Ref_Colors (Ref).Lab);
            if Dist < Min_Dist then
               Min_Dist  := Dist;
               New_Color := Ref;
            end if;
         end loop;
         if Min_Dist > 750.0 then
            New_Color := Candy_White;
         end if;

         if New_Color /= Candy_White then
            Color_Cnt (New_Color) := Color_Cnt (New_Color) + 1;
         end if;

         FB.Data.all (Index) := To_Short (Ref_Colors (New_Color).C);
      end loop;

      --  Show the dominant color
      Cnt := 0;
      New_Color := Candy_White;
      for C in Candy_Colors loop
         if Color_Cnt (C) > Cnt then
            New_Color := C;
            Cnt := Color_Cnt (C);
         end if;
      end loop;

      for X in Width'Last - 5 .. Width'Last loop
         for Y in Height'Range loop
            Set_Pixel (X, Y, Ref_Colors (New_Color).C);
         end loop;
      end loop;
   end Test;

end OpenMV.Image;
