with STM32.Board; use STM32.Board;

package body Harmonica is

   ----------
   -- Init --
   ----------

   procedure Init is
   begin
      STM32.Board.Initialize_LEDs;
   end Init;

   ----------
   -- Play --
   ----------

   procedure Play (Notes : GPIO_Points; Len : Time_Span) is
   begin
      Set (Notes);
      delay until Clock + Len;
      Clear (Notes);
   end Play;

   ----------
   -- Play --
   ----------

   procedure Play (Note : GPIO_Point; Len : Time_Span) is
   begin
      Set (Note);
      delay until Clock + Len;
      Clear (Note);
   end Play;

   -------------
   -- Silence --
   -------------

   procedure Silence (Len : Time_Span) is
   begin
      delay until Clock + Len;
   end Silence;

end Harmonica;
