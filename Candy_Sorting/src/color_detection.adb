package body Color_Detection is

   type Pixel_To_Candy_Color_Array is array (Short) of Candy_Colors
     with Pack, Size => 65536 * 3;

   Convert_Table : Pixel_To_Candy_Color_Array;
   Is_Initialized : Boolean := False;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize is
      Ref_Lab        : array (Candy_Colors) of LAB_Color;
      Lab            : LAB_Color;
      Dist           : Float;
      Min_Dist       : Float;
      Detected_Color : Candy_Colors;

   begin
      for Candy in Candy_Colors loop
         Ref_Lab (Candy) := To_LAB (Reference_Color (Candy));
      end loop;

      for Pix in Short loop
         Lab := To_LAB (Word_To_Bitmap_Color (RGB_565, Word (Pix)));
         Detected_Color := Candy_White;
         Min_Dist := Float'Last;
         for Ref in Candy_Colors loop
            Dist := Distance (Lab, Ref_Lab (Ref));
            if Dist < Min_Dist then
               Min_Dist  := Dist;
               Detected_Color := Ref;
            end if;
         end loop;
         if Min_Dist > 750.0 then
            Detected_Color := Candy_White;
         end if;

         Convert_Table (Pix) := Detected_Color;
      end loop;
      Is_Initialized := True;
   end Initialize;

   -----------------
   -- Initialized --
   -----------------

   function Initialized return Boolean is
   begin
      return Is_Initialized;
   end Initialized;

   --------------------------
   -- Pixel_To_Candy_Color --
   --------------------------

   function Pixel_To_Candy_Color
     (Pix : Short)
      return Candy_Colors
   is
   begin
      return Convert_Table (Pix);
   end Pixel_To_Candy_Color;

   ------------------
   -- Filter_Image --
   ------------------

   procedure Filter_Image (BM : Bitmap_Buffer'Class;
                           Region_X, Region_Y,
                           Region_W, Region_H : Integer := 0)
   is
      Pix_Word : Word;
      Candy    : Candy_Colors;
      Cnt      : Natural := 0;
      Stop_X : constant Integer :=
        (if Region_W = 0 then BM.Width - 1 else Region_X + Region_W);
      Stop_Y : constant Integer :=
        (if Region_H = 0 then BM.Height - 1 else Region_Y + Region_H);
   begin
      --  Display a line of each reference color
      for Ref of Reference_Color loop
         for X in Cnt * 5 .. (Cnt + 1) * 5 - 1 loop
            for Y in 0 .. BM.Height - 1 loop
               BM.Set_Pixel (X, Y, Ref);
            end loop;
         end loop;
         Cnt := Cnt + 1;
      end loop;

      for X in Region_X .. Stop_X loop
         for Y in Region_Y .. Stop_Y loop
            Pix_Word := BM.Get_Pixel (X, Y);
            Candy := Pixel_To_Candy_Color (Short (Pix_Word));
            Pix_Word := Bitmap_Color_To_Word (RGB_565,
                                              Reference_Color (Candy));
            BM.Set_Pixel (X, Y, Pix_Word);
         end loop;
      end loop;
   end Filter_Image;

end Color_Detection;
