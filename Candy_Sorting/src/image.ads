with HAL.Bitmap; use HAL.Bitmap;

package Image is

   type Candy_Colors is (Candy_Red, Candy_Orange, Candy_Yellow, Candy_Green,
                         Candy_Blue, Candy_Brown, Candy_White)
     with Size => 3;

   Reference_Color : array (Candy_Colors) of Bitmap_Color :=
     (Candy_Red    => Brown,
      Candy_Orange => Orange,
      Candy_Yellow => Yellow,
      Candy_Green  => Lime_Green,
      Candy_Blue   =>  Medium_Blue,
      Candy_Brown  => Black,
      Candy_White  => White);

   type RGB_Float is record
      R, G, B : Float := 0.0;
   end record;

   type HSV_Color is record
      H, S, V : Float := 0.0;
   end record;

   type LAB_Color is record
      L, A, B : Float := 0.0;
   end record;

   function To_RGB (C : Bitmap_Color) return RGB_Float with Inline_Always;
   function To_HSV (C : RGB_Float) return HSV_Color with Inline_Always;
   function To_LAB (C : Bitmap_Color) return LAB_Color with Inline_Always;
   function Distance (C1, C2 : LAB_Color) return Float with Inline_Always;
   function Distance (C1, C2 : Bitmap_Color) return Float with Inline_Always;

end Image;
