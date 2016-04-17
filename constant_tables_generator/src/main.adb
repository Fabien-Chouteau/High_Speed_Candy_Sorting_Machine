--  Based on gen_rgb2lab.py from the OpenMV project (openmv.io)
--
--  https://github.com/openmv/openmv/blob/master/util/gen_rgb2lab.py
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Numerics.Generic_Elementary_Functions;

procedure Main is

   subtype Float_Type is Long_Float;

   package Float_Functions is new
     Ada.Numerics.Generic_Elementary_Functions (Float_Type);
   use Float_Functions;

   package Float_IO is new Ada.Text_IO.Float_IO (Float_Type);

   function Lin (C : Float_Type) return Float_Type is
     (100.0 * (if C <= 0.04045
               then
                  C / 12.92
               else
                  (C + 0.055) / 1.055) ** 2.4);

   function F (C : Float_Type) return Float_Type is
     (if C > 0.008856
      then
         C ** (1.0 / 3.0)
      else
         C * 7.787037 +0.137931);

   Rf, Gf, Bf : Float_Type;
   X, Y, Z : Float_Type;
   L, A, Bs : Integer;

   XYZ_Table : constant Boolean := True;
   Lab_Table : constant Boolean := False;
begin
   Put_Line ("--  Do not touch! This file was automgically generated.");
   Put_Line ("with OpenMV.Image; use OpenMV.Image;");
   Put_Line ("package OpenMV.Constant_Tables is");

   if LAB_Table then
      Put_Line ("   type LAB_Int is record");
      Put_Line ("      L, A, B : Unsigned_8;");
      Put_Line ("   end record with Pack;");
      Put_Line ("");
      Put_Line ("      LAB_Table : array (0 .. 31, 0 .. 63, 0 .. 31) of LAB_Int := (");
      for R in 0 .. 31 loop
         Put_Line ("     (");
         for G in 0 .. 63 loop
            Put_Line ("     (");
            for B in 0 .. 31 loop
               Rf := Lin (Float_Type (R * 2**3) / 255.0);
               Gf := Lin (Float_Type (G * 2**2) / 255.0);
               Bf := Lin (Float_Type (B * 2**3) / 255.0);

               X := (Rf * 0.4124) + (Gf * 0.3576) + (Bf * 0.1805);
               Y := (Rf * 0.2126) + (Gf * 0.7152) + (Bf * 0.0722);
               Z := (Rf * 0.0193) + (Gf * 0.1192) + (Bf * 0.9505);

               X := F (X / 95.047);
               Y := F (Y / 100.000);
               Z := F (Z / 108.883);

               L  := Integer (116.0 * Y) - 16;
               A  := Integer (500.0 * (X - Y));
               Bs := Integer (200.0 * (Y - Z));
               Put ("(" & L'Img & ", " & A'Img & ", " & Bs'Img & ")");
               if B = 255 or else (B mod 4) = 3 then
                  Put_Line (",");
               else
                  Put (", ");
               end if;
            end loop;
            if G = 255 then
               Put_Line (")");
            else
               Put_Line ("),");
            end if;
         end loop;
         if R = 255 then
            Put_Line (")");
         else
            Put_Line ("),");
         end if;
      end loop;
      Put_Line ("        );");
   end if;
   if XYZ_Table then
      Put_Line ("   XYZ_Table : array (RGB_Component) of Float := (");
      Put ("     ");
      for X in 0 .. 255 loop
         Float_IO.Put (Lin (Float_Type (X) / 255.0), 0, 7, 0);
         if X /= 255 then
            Put (",");
         end if;
         if X mod 6 = 5 then
            New_Line;
            Put ("     ");
         elsif X /= 255 then
            Put (" ");
         end if;
      end loop;
      Put_Line (");");
   end if;

   New_Line;
   Put_Line ("end OpenMV.Constant_Tables;");
end Main;
