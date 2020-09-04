BEGIN       {
                executed=0;
                missed=0;
            }
END         {
                total = executed + missed;
                if ( total != 0) {
                    printf("%.2f\n", executed * 100 / total);
                }
                else {
                    printf("00.00\n");
                }
            }
/^ *-:/     {
                # Ignore Lines that can not be executed.
                next;
            }
/^ *#####:/ {missed++;next;}
            {executed++;}
