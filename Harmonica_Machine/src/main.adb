with Ada.Real_Time; use Ada.Real_Time;
with Harmonica; use Harmonica;
with STM32.GPIO; use STM32.GPIO;
with STM32.Board; use STM32.Board;

procedure Main is
   S  : constant Time_Span := Milliseconds (125);
   M  : constant Time_Span := S * 2;
   L  : constant Time_Span := M * 2;
   XL : constant Time_Span := L * 2;
begin
   Init;
   STM32.Board.Configure_User_Button_GPIO;
   loop
      while not Set (User_Button_Point) loop
         null;
      end loop;
      Play (C, S);
      Silence (S);
      Play (C, S);
      Silence (S);
      Play (E, S);
      Silence (S);
      Play (C, S);
      Silence (S);
      Play (G, L);
      Play (E, L);

      Play (C, S);
      Silence (S);
      Play (C, S);
      Silence (S);
      Play (E, S);
      Silence (S);
      Play (G, S);
      Silence (S);
      Play (Low_C, XL);

      Play (C, S);
      Silence (S);
      Play (C, S);
      Silence (S);
      Play (E, S);
      Silence (S);
      Play (C, S);
      Silence (S);
      Play (G, L);
      Play (E, L);

      Play (C, M);
      Play (G, M);
      Play (E, L);
      Play (C, XL);
   end loop;
end Main;
