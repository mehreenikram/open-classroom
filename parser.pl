#!/usr/bin/env perl

use lib './lib';
# use Parser;
# use Util;
# use Scripts;
use strict;
use warnings;
use List::Util qw( min max );
#use Array::Utils qw(:all);
use 5.010;


#16/9/2015
#$$$$$$$$$$$$$$$$$$$$$$$4
#This function will print 3,2,-1,1 current,next,difference,frequency of that occurance
#INPUT MFR_Input.txt each line represent 1 use the sequence he follows

#findBackWardAndGap();
sub findBackWardAndGap{
	my $infile = "./MFR_Input.txt";	
	my @arrayOfAllSeqIDs=readFileLinebyLineInArray($infile);
	
	my @arrayToPrint;
	my $strToPrint;
	my @arrayOfSeqGAP;
	for (my $i=0; $i <=$#arrayOfAllSeqIDs; $i++)
	{
#		print ("$arrayOfAllSeqIDs[$i]\n\n");
		my $arrayOfAllSeqIDsStr = $arrayOfAllSeqIDs[$i];
		my @arrA= split(/\s/, $arrayOfAllSeqIDsStr);
		for (my $j=0; $j <=$#arrA; $j++)
		{	
			my $current=$arrA[$j];
			my $nextIndex=$j+1;
			my $next=$arrA[$nextIndex];			
			#print ("$nextIndex\n");			
			if($nextIndex<=$#arrA)
			{
				my $diff=$next-$current;
				{
					push @arrayOfSeqGAP,"$current,$next,$diff",
				}
				
			}
		}
	}	
	my  @array = @arrayOfSeqGAP;
	my ($temp, $count) = ("@array", 0);
	($count = $temp =~ s/($_)//g) and printf "%2d,%s\n", $count, $_ and push @arrayToPrint, "$_,$count\n" for @array;
	
	writeArrayToFile("./GAPSwithFrequency.txt",@arrayToPrint);

}


#   largeReferenceSequence();
#   takes in 2 files
#   "./LRS_Input.txt" 609 rows, each line represent a student and its MFRs sperated by -1 and are the pruned ones
#   these are then given to SPMF Algo:CM-SPAM supp:0.05 and the ouput is saved in "./LRS_Output.txt" from which the 
#   support is removed and used in this in a comparison manner to calculate the correct support.

# here is used the string comparisons so '4 5 15' is not equal to '4 5 6 15'
#although in actual we may have the instances '4 5 6 15' but while finding the support of '4 5 15' we wont count '4 5 6 15'

#That is why SPMF was giving high support for some cases whereas this algo gives low support to them
# e.g. SPMF:                 Line 4439: 4 5 13 -1 SUP: 75
#      the following code:   2 4 5 13  	Sup:	0

sub largeReferenceSequence{
	my $infile = "./LRS_Input.txt";	
	my @arrayLRSInput=readFileLinebyLineInArray($infile);
	my $infile1 = "./LRS_Output.txt";	
	my @arrayLRSOutput=readFileLinebyLineInArray($infile1);
	my @printArray;
	for (my $i=0; $i <=$#arrayLRSOutput; $i++)
	{	
		my $arrayLRSOutputStr=" $arrayLRSOutput[$i] ";
		print ("$i\n");
		my $count=0;
		my $instances="";
		for (my $j=0; $j <=$#arrayLRSInput; $j++)
		{
			my $arrayLRSInputStr=$arrayLRSInput[$j];
			if(index($arrayLRSInputStr,$arrayLRSOutputStr)!=-1) #find the string of Output file in Input file
			{
				$count=$count+1;
				my $inst=$j+1;
				$instances=$instances." ".$inst;
				print ("$arrayLRSOutputStr is in $arrayLRSInputStr Count:$count\n");

			}
		}
		my $arrayLRSOutputStrPrint;
		if ($count>0)
		{
			$arrayLRSOutputStrPrint="$arrayLRSOutputStr ,Sup:,$count,Inst:$instances\n";
		}
		else
		{
			$arrayLRSOutputStrPrint="$arrayLRSOutputStr ,Sup:,$count\n";		
		}
		push @printArray,$arrayLRSOutputStrPrint;
	
	}

	print ("\n\n");		

	for (my $i=0; $i <=$#printArray; $i++)
	{
		print ("$printArray[$i]");		
	}
	writeArrayToFile("./LRS.txt",@printArray);


}

#formArrays1();
sub formArrays1{
	my $infile = "./MFR_Input1.txt";	
	my @arrayOfAllSeqIDs=readFileLinebyLineInArray($infile);
	unlink("./Strange.txt");  # delete the old file
	
	for (my $i=0; $i <=$#arrayOfAllSeqIDs; $i++)
	{
#		print ("$arrayOfAllSeqIDs[$i]\n");
	my @maxForRefForStudent=Maximal_Forward_Reference_All_withoutProuning_Ratio($arrayOfAllSeqIDs[$i]);   # here change the prog call
#	my @maxForRefForStudent=Maximal_Forward_Reference_All_withProuning_Ratio($arrayOfAllSeqIDs[$i]);   # here change the prog call

	my @tempp=('mmm');
	push @maxForRefForStudent,@tempp;
	writeArrayToFileAppend("./Strange.txt",@maxForRefForStudent);
	}
}



#MFR STAGE 3 Witht Ratio
sub Maximal_Forward_Reference_All_withoutProuning_Ratio{
#CORRECT
#	my @arrA=('null','a','b','c','d','c','b','e','g','h','g','w','a','o','u','o'); 
#	       my @arrB=('a','b','c','d','c','b','e','g','h','g','w','a','o','u','o','v');
#	my @arrA=('null','1','2','3','4','3','2','5','7','8','7','23','1','15','21','15');
#	       my @arrB=('1','2','3','4','3','2','5','7','8','7','23','1','15','21','15','22');

#	my @arrA=('null','a','bb','cc','d','cc','bb','e','g','h','g','w','a','oo','u','oo','v','a'); 
#	       my @arrB=('a','bb','cc','d','cc','bb','e','g','h','g','w','a','oo','u','oo','v','a','z');


#	my @arrA=('null','1','2','3','4','3','2','5','7','8','7','23','1','15','21','15');
#	       my @arrB=('1','2','3','4','3','2','5','7','8','7','23','1','15','21','15','22');


		my $arrayOfAllSeqIDs = shift;
		print ("Array Received:$arrayOfAllSeqIDs \n\n\n\n");	
#________________________________
		my @arrA= split(/\s/, $arrayOfAllSeqIDs);
		my @arrB= split(/\s/, $arrayOfAllSeqIDs);
		my $sizeOfInput=0;
		$sizeOfInput=$#arrA+1;
		print ("arrAold:@arrA\n");
		print ("arrBold:@arrB\n");

		my @arrnull=('null');
		push @arrnull,@arrA;
		@arrA= @arrnull;
		print ("arrAnew:@arrA\n");

		pop @arrA;
		print ("arrBnew:@arrB\n\n\n");

#___________________________________

	my $strY="";
	my $f=1;
	my $a="";
	my $b="";
	my @arrDF;

 #my $temp="abcdef";
 #my $len=length($temp);
# $len=$len-1;
# my $short = substr( $temp, 0, $len );
# print ("$len $temp $short\n\n\n\n");

# my $result = index($temp, 'd');
# print ("$len $result\n\n\n\n");


	#STEP 1
	for (my $i=0; $i <=$#arrB; $i++)
	{	$f=1;
		$a=$arrA[$i];
		$b=$arrB[$i];
		print ("______________________iteration # $i: a=$a   b=$b\n");
		
		#STEP 2
		if(index($a,'null')!=-1)   # if a is NULL
		{
			print("a is NULL\n");
			
			if($strY eq "")   
			{
				print("Y is NULL\n");
			}
			else
			{
				print("Y is not NULL\n");
				print("push 1 @arrDF, $strY\n");
				push @arrDF, $strY;
				
				$f=0;
				$strY=$b;
			}
		}

		#STEP 3
		if(index($strY,$b)!=-1)   # if b is contained in strY and assume b is never null
		{
			print("Inside STEP 3 strY Old= $strY, b=$b \n");
			if ($f==1)
			{
				my $checkFlagToPush=0;
				print("check if $strY is contained in any of the elements of @arrDF\n");
				foreach $a (@arrDF){
					print "\nvalue of arrDF:$a strY:$strY\n";
					if(index($a,$strY)!=-1)
					{
						print("$strY is in one of arrDF i.e. $a\n");
						$checkFlagToPush=1;							
					}
					else
					{
						print("$strY is not in one of arrDF i.e. $a\n");
						
					}
				}
				if($checkFlagToPush==0)
				{
					print("push 2 @arrDF, $strY\n");
					push @arrDF, $strY;
				}
				#$strY=$strYprev;
				# my $strYlength=length($strY);
				# $strYlength=$strYlength-1;
				# $strY = substr( $strY, 0, $strYlength );
				
				#DISCARD ALL THE REFERENCES AFTER Jth ONE IN STRING 'Y'
				my $result = index($strY, $b);
				print ("\nGOING TO DISCARD| result:$result  strY:$strY b:$b");
				$strY = substr( $strY, 0, $result+2 );   ############1
				print ("\nAfter    DISCARD| result:$result  strY:$strY b:$b\n");

				$f=0;
				print ("f==1\n strY New=$strY \n");

			}
		}

		#STEP 4
		else
		{	print("Inside STEP 4 \n");
			$strY=$strY.','.$b;	##############		
			if($i==$#arrB)
			{
				print("LAst*******************************");
				push @arrDF, $strY;
			}
			if ($f==0)
			{
				$f=1;
			}
		}		
		print ("\nOutside loop $i  strY=$strY arrDF=@arrDF\n");
	}	
		print ("\nOutside loop complete*************************************** \n>>>>>>  arrDF=\n\n");
		for (my $i=0; $i <=$#arrDF; $i++)
		{		
			print("$arrDF[$i]\n");
		}
		
		# print("\nKeeping only the Maximals\n");
		# for (my $i=0; $i <=$#arrDF; $i++)
		# {
			# for (my $j=1; $j <=$#arrDF; $j++)
			# {
				# print ("To check:$arrDF[$i]___To Check in:$arrDF[$j]");
				# if(index($arrDF[$j],$arrDF[$i])!=-1)   # if i is contained in j and assume b is never null
				# {
					# print("\n$arrDF[$i] is contaiend in  $arrDF[$j]\n");
					# splice @arrDF, $i, 1;
				# }
				# else
				# {
					# print("\n$arrDF[$i] is not contaiend in  $arrDF[$j]\n");
				# }
			# }		
		# }
		# print ("\nOutside loop complete MAXIMALS*************************************** \n>>>>>>  arrDF=\n\n");
		# for (my $i=0; $i <=$#arrDF; $i++)
		# {		
			# print("$arrDF[$i]\n");
		# }
	my @outputElem;
		print ("\nOutside loop complete MAXIMALS*************************************** \n>>>>>>  arrDF=\n");
		for (my $i=0; $i <=$#arrDF; $i++)
		{		
			print("Before Split:$arrDF[$i]\n");
			my @outputElemPart= split(/,/, $arrDF[$i]);
			print ("Split:@outputElemPart\n");
			push @outputElem,@outputElemPart;
		}

		print("\nFinal one \n ");
		my @outputElemFinal;
		for (my $i=0; $i <=$#outputElem; $i++)
		{		
			print("$i:$outputElem[$i]< ");
			if ($outputElem[$i] eq "")
			{
				
			}
			else
			{
				push @outputElemFinal,$outputElem[$i];
			}
			
		}
		
		
#		writeArrayToFile("./Strange.txt",@arrDF);
my $outputElemFinalSiz=$#outputElemFinal + 1;
my $ratio=$outputElemFinalSiz/$sizeOfInput;
my $roundedRatio = sprintf "%.2f", $ratio;
push @arrDF," Inp:$sizeOfInput Oup:$outputElemFinalSiz Ratio:$roundedRatio";  				

return @arrDF;
}


#MFR STAGE 4
sub Maximal_Forward_Reference_All_withProuning_Ratio{
#CORRECT
#	my @arrA=('null','a','b','c','d','c','b','e','g','h','g','w','a','o','u','o'); 
#	       my @arrB=('a','b','c','d','c','b','e','g','h','g','w','a','o','u','o','v');
#	my @arrA=('null','1','2','3','4','3','2','5','7','8','7','23','1','15','21','15');
#	       my @arrB=('1','2','3','4','3','2','5','7','8','7','23','1','15','21','15','22');

#	my @arrA=('null','a','bb','cc','d','cc','bb','e','g','h','g','w','a','oo','u','oo','v','a'); 
#	       my @arrB=('a','bb','cc','d','cc','bb','e','g','h','g','w','a','oo','u','oo','v','a','z');


#	my @arrA=('null','1','2','3','4','3','2','5','7','8','7','23','1','15','21','15');
#	       my @arrB=('1','2','3','4','3','2','5','7','8','7','23','1','15','21','15','22');

	my $sizeOfInput=0;
	
	my $arrayOfAllSeqIDs = shift;
	print ("Array Received:$arrayOfAllSeqIDs \n\n\n\n");	
	#________________________________
		my @arrA= split(/\s/, $arrayOfAllSeqIDs);
		my @arrB= split(/\s/, $arrayOfAllSeqIDs);
		$sizeOfInput=$#arrA+1;
		print ("arrAold:@arrA\n");
		print ("arrBold:@arrB\n");

		my @arrnull=('null');
		push @arrnull,@arrA;
		@arrA= @arrnull;
		print ("arrAnew:@arrA\n");

		pop @arrA;
		print ("arrBnew:@arrB\n\n\n");

	#___________________________________

	my $strY="";
	my $f=1;
	my $a="";
	my $b="";
	my @arrDF;

	 #my $temp="abcdef";
	 #my $len=length($temp);
	# $len=$len-1;
	# my $short = substr( $temp, 0, $len );
	# print ("$len $temp $short\n\n\n\n");

	# my $result = index($temp, 'd');
	# print ("$len $result\n\n\n\n");


	#STEP 1
	for (my $i=0; $i <=$#arrB; $i++)
	{	$f=1;
		$a=$arrA[$i];
		$b=$arrB[$i];
		print ("______________________iteration # $i: a=$a   b=$b\n");
		
		#STEP 2
		if(index($a,'null')!=-1)   # if a is NULL
		{
			print("a is NULL\n");
			
			if($strY eq "")   
			{
				print("Y is NULL\n");
			}
			else
			{
				print("Y is not NULL\n");
				print("push 1 @arrDF, $strY\n");
				push @arrDF, $strY;
				$f=0;
				$strY=$b;
			}
		}

		#STEP 3
		if(index($strY,$b)!=-1)   # if b is contained in strY and assume b is never null
		{
			print("Inside STEP 3 strY Old= $strY, b=$b \n");
			if ($f==1)
			{
				my $checkFlagToPush=0;
				print("check if $strY is contained in any of the elements of @arrDF\n");
				foreach $a (@arrDF){
					print "\nvalue of arrDF:$a strY:$strY\n";
					if(index($a,$strY)!=-1)
					{
						print("$strY is in one of arrDF i.e. $a\n");
						$checkFlagToPush=1;							
					}
					else
					{
						print("$strY is not in one of arrDF i.e. $a\n");
						
					}
				}
				if($checkFlagToPush==0)
				{
					print("push 2 @arrDF, $strY\n");
					push @arrDF, $strY;
				}
				#$strY=$strYprev;
				# my $strYlength=length($strY);
				# $strYlength=$strYlength-1;
				# $strY = substr( $strY, 0, $strYlength );
				
				#DISCARD ALL THE REFERENCES AFTER Jth ONE IN STRING 'Y'
				my $result = index($strY, $b);
				print ("\nGOING TO DISCARD| result:$result  strY:$strY b:$b");
				$strY = substr( $strY, 0, $result+2 );   ############1
				print ("\nAfter    DISCARD| result:$result  strY:$strY b:$b\n");

				$f=0;
				print ("f==1\n strY New=$strY \n");

			}
		}

		#STEP 4
		else
		{	print("Inside STEP 4 \n");
			$strY=$strY.','.$b;	##############		
			if($i==$#arrB)
			{
				print("LAst*******************************");
				push @arrDF, $strY;
			}
			if ($f==0)
			{
				$f=1;
			}
		}		
		# print ("\nOutside loop $i  strY=$strY arrDF=@arrDF\n");
	}	
		# print ("\nOutside loop complete*************************************** \n>>>>>>  arrDF=\n\n");
		# for (my $i=0; $i <=$#arrDF; $i++)
		# {		
			# print("$arrDF[$i]\n");
		# }
		
		#pruning
		print("\nKeeping only the Maximals\n");
		for (my $i=0; $i <=$#arrDF; $i++)
		{
			for (my $j=1; $j <=$#arrDF; $j++)
			{
				print ("To check:$arrDF[$i]___To Check in:$arrDF[$j]");
				if(index($arrDF[$j],$arrDF[$i])!=-1)   # if i is contained in j and assume b is never null
				{
					print("\n$arrDF[$i] is contaiend in  $arrDF[$j]\n");
					splice @arrDF, $i, 1;
				}
				else
				{
					print("\n$arrDF[$i] is not contaiend in  $arrDF[$j]\n");
				}
			}		
		}
		my @outputElem;
		print ("\nOutside loop complete MAXIMALS*************************************** \n>>>>>>  arrDF=\n");
		for (my $i=0; $i <=$#arrDF; $i++)
		{		
			print("Before Split:$arrDF[$i]\n");
			my @outputElemPart= split(/,/, $arrDF[$i]);
			print ("Split:@outputElemPart\n");
			push @outputElem,@outputElemPart;
		}

		print("\nFinal one \n ");
		my @outputElemFinal;
		for (my $i=0; $i <=$#outputElem; $i++)
		{		
			print("$i:$outputElem[$i]< ");
			if ($outputElem[$i] eq "")
			{
				
			}
			else
			{
				push @outputElemFinal,$outputElem[$i];
			}
			
		}
		
#		writeArrayToFile("./Strange.txt",@arrDF);
my $outputElemFinalSiz=$#outputElemFinal + 1;
my $ratio=$outputElemFinalSiz/$sizeOfInput;
my $roundedRatio = sprintf "%.2f", $ratio;
push @arrDF," Inp:$sizeOfInput Oup:$outputElemFinalSiz Ratio:$roundedRatio";  				
return @arrDF;
}


#MFR STAGE 3
sub Maximal_Forward_Reference_All_withoutProuning{
#CORRECT
#	my @arrA=('null','a','b','c','d','c','b','e','g','h','g','w','a','o','u','o'); 
#	       my @arrB=('a','b','c','d','c','b','e','g','h','g','w','a','o','u','o','v');
#	my @arrA=('null','1','2','3','4','3','2','5','7','8','7','23','1','15','21','15');
#	       my @arrB=('1','2','3','4','3','2','5','7','8','7','23','1','15','21','15','22');

#	my @arrA=('null','a','bb','cc','d','cc','bb','e','g','h','g','w','a','oo','u','oo','v','a'); 
#	       my @arrB=('a','bb','cc','d','cc','bb','e','g','h','g','w','a','oo','u','oo','v','a','z');


#	my @arrA=('null','1','2','3','4','3','2','5','7','8','7','23','1','15','21','15');
#	       my @arrB=('1','2','3','4','3','2','5','7','8','7','23','1','15','21','15','22');


		my $arrayOfAllSeqIDs = shift;
		print ("Array Received:$arrayOfAllSeqIDs \n\n\n\n");	
#________________________________
		my @arrA= split(/\s/, $arrayOfAllSeqIDs);
		my @arrB= split(/\s/, $arrayOfAllSeqIDs);
				
		print ("arrAold:@arrA\n");
		print ("arrBold:@arrB\n");

		my @arrnull=('null');
		push @arrnull,@arrA;
		@arrA= @arrnull;
		print ("arrAnew:@arrA\n");

		pop @arrA;
		print ("arrBnew:@arrB\n\n\n");

#___________________________________

	my $strY="";
	my $f=1;
	my $a="";
	my $b="";
	my @arrDF;

 #my $temp="abcdef";
 #my $len=length($temp);
# $len=$len-1;
# my $short = substr( $temp, 0, $len );
# print ("$len $temp $short\n\n\n\n");

# my $result = index($temp, 'd');
# print ("$len $result\n\n\n\n");


	#STEP 1
	for (my $i=0; $i <=$#arrB; $i++)
	{	$f=1;
		$a=$arrA[$i];
		$b=$arrB[$i];
		print ("______________________iteration # $i: a=$a   b=$b\n");
		
		#STEP 2
		if(index($a,'null')!=-1)   # if a is NULL
		{
			print("a is NULL\n");
			
			if($strY eq "")   
			{
				print("Y is NULL\n");
			}
			else
			{
				print("Y is not NULL\n");
				print("push 1 @arrDF, $strY\n");
				push @arrDF, $strY;
				
				$f=0;
				$strY=$b;
			}
		}

		#STEP 3
		if(index($strY,$b)!=-1)   # if b is contained in strY and assume b is never null
		{
			print("Inside STEP 3 strY Old= $strY, b=$b \n");
			if ($f==1)
			{
				my $checkFlagToPush=0;
				print("check if $strY is contained in any of the elements of @arrDF\n");
				foreach $a (@arrDF){
					print "\nvalue of arrDF:$a strY:$strY\n";
					if(index($a,$strY)!=-1)
					{
						print("$strY is in one of arrDF i.e. $a\n");
						$checkFlagToPush=1;							
					}
					else
					{
						print("$strY is not in one of arrDF i.e. $a\n");
						
					}
				}
				if($checkFlagToPush==0)
				{
					print("push 2 @arrDF, $strY\n");
					push @arrDF, $strY;
				}
				#$strY=$strYprev;
				# my $strYlength=length($strY);
				# $strYlength=$strYlength-1;
				# $strY = substr( $strY, 0, $strYlength );
				
				#DISCARD ALL THE REFERENCES AFTER Jth ONE IN STRING 'Y'
				my $result = index($strY, $b);
				print ("\nGOING TO DISCARD| result:$result  strY:$strY b:$b");
				$strY = substr( $strY, 0, $result+2 );   ############1
				print ("\nAfter    DISCARD| result:$result  strY:$strY b:$b\n");

				$f=0;
				print ("f==1\n strY New=$strY \n");

			}
		}

		#STEP 4
		else
		{	print("Inside STEP 4 \n");
			$strY=$strY.','.$b;	##############		
			if($i==$#arrB)
			{
				print("LAst*******************************");
				push @arrDF, $strY;
			}
			if ($f==0)
			{
				$f=1;
			}
		}		
		print ("\nOutside loop $i  strY=$strY arrDF=@arrDF\n");
	}	
		print ("\nOutside loop complete*************************************** \n>>>>>>  arrDF=\n\n");
		for (my $i=0; $i <=$#arrDF; $i++)
		{		
			print("$arrDF[$i]\n");
		}
		
		# print("\nKeeping only the Maximals\n");
		# for (my $i=0; $i <=$#arrDF; $i++)
		# {
			# for (my $j=1; $j <=$#arrDF; $j++)
			# {
				# print ("To check:$arrDF[$i]___To Check in:$arrDF[$j]");
				# if(index($arrDF[$j],$arrDF[$i])!=-1)   # if i is contained in j and assume b is never null
				# {
					# print("\n$arrDF[$i] is contaiend in  $arrDF[$j]\n");
					# splice @arrDF, $i, 1;
				# }
				# else
				# {
					# print("\n$arrDF[$i] is not contaiend in  $arrDF[$j]\n");
				# }
			# }		
		# }
		# print ("\nOutside loop complete MAXIMALS*************************************** \n>>>>>>  arrDF=\n\n");
		# for (my $i=0; $i <=$#arrDF; $i++)
		# {		
			# print("$arrDF[$i]\n");
		# }
		
		
#		writeArrayToFile("./Strange.txt",@arrDF);
return @arrDF;
}

#MFR STAGE 2
# keeping the maximals only but not pruning, 
# e.g. if we have 1,2,3 and later 0,1,2,3,4,5 then both exist
#      if we have 0,1,2,3,4,5 and later 1,2,3 then the 2nd one "1,2,3" is not included

#Maximal_Forward_Reference_Numer_MAX();
sub Maximal_Forward_Reference_Numer_MAX{
#CORRECT
	my @arrA=('null','a','b','c','d','c','b','e','g','h','g','w','a','o','u','o'); 
	       my @arrB=('a','b','c','d','c','b','e','g','h','g','w','a','o','u','o','v');
#	my @arrA=('null','1','2','3','4','3','2','5','7','8','7','23','1','15','21','15');
#	       my @arrB=('1','2','3','4','3','2','5','7','8','7','23','1','15','21','15','22');

#	my @arrA=('null','a','bb','cc','d','cc','bb','e','g','h','g','w','a','oo','u','oo','v','a'); 
#	       my @arrB=('a','bb','cc','d','cc','bb','e','g','h','g','w','a','oo','u','oo','v','a','z');


#	my @arrA=('null','1','2','3','4','3','2','5','7','8','7','23','1','15','21','15');
#	       my @arrB=('1','2','3','4','3','2','5','7','8','7','23','1','15','21','15','22');
	my $strY="";
	my $f=1;
	my $a="";
	my $b="";
	my @arrDF;

 #my $temp="abcdef";
 #my $len=length($temp);
# $len=$len-1;
# my $short = substr( $temp, 0, $len );
# print ("$len $temp $short\n\n\n\n");

# my $result = index($temp, 'd');
# print ("$len $result\n\n\n\n");


	#STEP 1
	for (my $i=0; $i <=$#arrB; $i++)
	{	$f=1;
		$a=$arrA[$i];
		$b=$arrB[$i];
		print ("______________________iteration # $i: a=$a   b=$b\n");
		
		#STEP 2
		if(index($a,'null')!=-1)   # if a is NULL
		{
			print("a is NULL\n");
			
			if($strY eq "")   
			{
				print("Y is NULL\n");
			}
			else
			{
				print("Y is not NULL\n");
				print("push 1 @arrDF, $strY\n");
				push @arrDF, $strY;
				
				$f=0;
				$strY=$b;
			}
		}
		#STEP 3
		if(index($strY,$b)!=-1)   # if b is contained in strY and assume b is never null
		{
			print("Inside STEP 3 strY Old= $strY, b=$b \n");
			if ($f==1)
			{
				my $checkFlagToPush=0;
				print("check if $strY is contained in any of the elements of @arrDF");
				foreach $a (@arrDF){
					print "\nvalue of arrDF:$a strY:$strY\n";
					if(index($a,$strY)!=-1)
					{
						print("$strY is in one of arrDF i.e. $a\n");
						$checkFlagToPush=1;							
					}
					else
					{
						print("$strY is not in one of arrDF i.e. $a\n");
						
					}
				}
				if($checkFlagToPush==0)
				{
					print("push 2 @arrDF, $strY\n");
					push @arrDF, $strY;
				}
				#$strY=$strYprev;
				# my $strYlength=length($strY);
				# $strYlength=$strYlength-1;
				# $strY = substr( $strY, 0, $strYlength );
				
				#DISCARD ALL THE REFERENCES AFTER Jth ONE IN STRING 'Y'
				my $result = index($strY, $b);
				print ("\nGOING TO DISCARD| result:$result  strY:$strY b:$b");
				$strY = substr( $strY, 0, $result+2 );   ############1
				print ("\nAfter    DISCARD| result:$result  strY:$strY b:$b\n");

				$f=0;
				print ("f==1\n strY New=$strY \n");

			}
		}
		#STEP 4
		else
		{	print("Inside STEP 4 \n");
			$strY=$strY.','.$b;	##############		
			if($i==$#arrB)
			{
				print("LAst*******************************");
				push @arrDF, $strY;
			}
			if ($f==0)
			{
				$f=1;
			}
		}
		
		print ("\nOutside loop >>>>>> $i  strY=$strY arrDF=@arrDF\n");

	}	
		print ("\nOutside loop complete \n>>>>>>  arrDF=@arrDF\n");
		
		#writeArrayToFile("./Strange.txt",@arrDF);

}


#MFR STAGE 1
#keeping all
#Maximal_Forward_Reference_Numer_ALL();
sub Maximal_Forward_Reference_Numer_ALL{
#CORRECT
	my @arrA=('null','a','b','c','d','c','b','e','g','h','g','w','a','o','u','o'); 
	       my @arrB=('a','b','c','d','c','b','e','g','h','g','w','a','o','u','o','v');
#	my @arrA=('null','1','2','3','4','3','2','5','7','8','7','23','1','15','21','15');
#	       my @arrB=('1','2','3','4','3','2','5','7','8','7','23','1','15','21','15','22');

#	my @arrA=('null','a','bb','cc','d','cc','bb','e','g','h','g','w','a','oo','u','oo','v','a'); 
#	       my @arrB=('a','bb','cc','d','cc','bb','e','g','h','g','w','a','oo','u','oo','v','a','z');


#	my @arrA=('null','1','2','3','4','3','2','5','7','8','7','23','1','15','21','15');
#	       my @arrB=('1','2','3','4','3','2','5','7','8','7','23','1','15','21','15','22');
	my $strY="";
	my $f=1;
	my $a="";
	my $b="";
	my @arrDF;

 #my $temp="abcdef";
 #my $len=length($temp);
# $len=$len-1;
# my $short = substr( $temp, 0, $len );
# print ("$len $temp $short\n\n\n\n");

# my $result = index($temp, 'd');
# print ("$len $result\n\n\n\n");


	#STEP 1
	for (my $i=0; $i <=$#arrB; $i++)
	{	$f=1;
		$a=$arrA[$i];
		$b=$arrB[$i];
		print ("______________________iteration # $i: a=$a   b=$b\n");
		
		#STEP 2
		if(index($a,'null')!=-1)   # if a is NULL
		{
			print("a is NULL\n");
			
			if($strY eq "")   
			{
				print("Y is NULL\n");
			}
			else
			{
				print("Y is not NULL\n");
				print("push 1 @arrDF, $strY\n");
				push @arrDF, $strY;
				
				$f=0;
				$strY=$b;
			}
		}
		#STEP 3
		if(index($strY,$b)!=-1)   # if b is contained in strY and assume b is never null
		{
			print("Inside STEP 3 strY Old= $strY, b=$b \n");
			if ($f==1)
			{
					print("push 2 @arrDF, $strY\n");
					push @arrDF, $strY;
				#$strY=$strYprev;
				# my $strYlength=length($strY);
				# $strYlength=$strYlength-1;
				# $strY = substr( $strY, 0, $strYlength );
				
				#DISCARD ALL THE REFERENCES AFTER Jth ONE IN STRING 'Y'
				my $result = index($strY, $b);
				print ("\nGOING TO DISCARD| result:$result  strY:$strY b:$b");
				$strY = substr( $strY, 0, $result+2 );   ############1
				print ("\nAfter    DISCARD| result:$result  strY:$strY b:$b\n");

				$f=0;
				print ("f==1\n strY New=$strY \n");

			}
		}
		#STEP 4
		else
		{	print("Inside STEP 4 \n");
			$strY=$strY.','.$b;	##############		
			if($i==$#arrB)
			{
				print("LAst*******************************");
				push @arrDF, $strY;
			}
			if ($f==0)
			{
				$f=1;
			}
		}
		
		print ("\nOutside loop >>>>>> $i  strY=$strY arrDF=@arrDF\n");

	}	
		print ("\nOutside loop complete \n>>>>>>  arrDF=@arrDF\n");
		
		#writeArrayToFile("./Strange.txt",@arrDF);

}




sub writeArrayToFileAppend
{
	my $fileName = shift;
	my (@arrayToWrite_ref) = @_;
	open (FILE, ">> $fileName") or die "problem opening $fileName\n";
	 foreach (@arrayToWrite_ref) {
		 #print FILE $_."\n";
		 print FILE $_."|";
	 }
	close(FILE);
}


sub writeArrayToFile
{
	my $fileName = shift;
	my (@arrayToWrite_ref) = @_;
	open (FILE, "> $fileName") or die "problem opening $fileName\n";
	 foreach (@arrayToWrite_ref) {
		 #print FILE $_."\n";
		 print FILE $_;
	 }
	close(FILE);
}

#findPatterns();
#compares 2 files: inorder to prune the sequences with gap
#nodejaINnew1.txt - > having sequences one line representing the sequence studied by the student.
#outputCollective.txt -> having the frequent sequences

sub findPatterns{
	
	my $infileCoreSeq = "E:/Dropbox/OpenClassRoom/perl/nodejaINnew1Apriori.txt";
	my $infileOutputSeq = "E:/Dropbox/OpenClassRoom/perl/outputCollective.txt";

	open(FH, $infileCoreSeq) or die "Cannot open $infileCoreSeq\n";
		my @infileCoreSeq;
		while ( my $line = <FH> )
		{
			chomp($line);
			push @infileCoreSeq,$line;		
#			print "$line\n";
		}
	print "\n\n\n";
	
	open(FH, $infileOutputSeq) or die "Cannot open $infileOutputSeq\n";
		my @infileOutputSeq;
		while ( my $line = <FH> )
		{
			chomp($line);
			my @first = split(/\s\#/, $line);
			my $firstElem = $first[0];
			my $support = $first[1];			
#			print "$firstElem\n";
#			print "$support\n";

			push @infileOutputSeq,$firstElem;		
#			print "$line\n";
		}

	print "\n\n\n";

my @freqSequences;
	foreach my $infileOutputSeq (@infileOutputSeq) {
		foreach my $infileCoreSeq (@infileCoreSeq) {
			if(index($infileCoreSeq,$infileOutputSeq)!=-1)
			{
				#print "f:\n$infileCoreSeq--->\n$infileOutputSeq\n\n";
				
				push @freqSequences,$infileOutputSeq;
				
			}
		}
	}

	my @freqSequencesUnique = do { my %seen; grep { !$seen{$_}++ } @freqSequences };
	my @freqSequencesUniqueWithSupport;
	my $freqSequencesUniqueWithSupportItem;
	
	foreach my $freqSequencesUnique (@freqSequencesUnique) 
	{			
		$freqSequencesUniqueWithSupportItem = "$freqSequencesUnique mm";
		print "f:$freqSequencesUniqueWithSupportItem";
	}	



	open (OUT, "> E:/Dropbox/OpenClassRoom/perl/freqSeq.txt") or die "problem opening  ./db/LamebrkPairsID.txt\n";
		foreach (@freqSequencesUnique) {
			print OUT $_;
		}
		close(OUT);
}

#IMPT
#time_user_processing();

sub time_user_processing{
	my $infile = "E:/Dropbox/OpenClassRoom/time_user_processing1.csv";	 
	open(FH, $infile) or die "Cannot open $infile\n";
	my $tempUser=0;
	my $partConcat="";
	my $partConcatOld="";
	my @timeKeep;
	my @printArray;
	my $pushElem=0;
	my $pushFlag=1;
	my @user;
	my @time;

	while ( my $line = <FH> )
	{
		chomp($line);
		my @values = split(',', $line);		
		my $userId=$values[0];
		my $timeSpace=$values[1];
		push @user,$userId;
		push @time,$timeSpace;
		
	}
	
	#print("\nTime kept:@timeKeep \n@user \n@time\n");
	#print ("\n\n"); 		
		
	for (my $i=0; $i <= $#user; $i++)
	{
		my $userId=$user[$i];
		my $nextIter=$i+1;
		my $nextUserId=$user[$nextIter];
		if($nextUserId)
		{
			#print ("\nUser:$userId  NextUser:$nextUserId");
			if ($userId eq $nextUserId)
			{
				push @timeKeep,"$user[$i],$time[$i]";
			} 		
		}
	}

	close(FH);	
	print ("\n\n"); 		
	print ("TimeKeep: @timeKeep"); 		

		open (OUT, "> E:/Dropbox/OpenClassRoom/time_for _plot.txt") or die "problem opening  nodejs_duration_arranged.txt\n";
		foreach (@timeKeep) {
			print OUT "$_\n";
			print("$_\n");
		}
		close(OUT);
	
}


#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^




#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ LAST USER ID NOT INCORPORATED, CHECK THIS
#user_id	session_id	             part_index	date	        end	         duration
#4744046	um8lqf6ejpqi8e1ucuidjk69s4	25	18/2/2014 19:20	18/2/2014 19:29	   511
#4744046	um8lqf6ejpqi8e1ucuidjk69s4	26	18/2/2014 19:29	18/2/2014 19:34	   295

##preprocessing_with_duration();

sub preprocessing_with_duration{
	my $infile = "E:/Dropbox/OpenClassRoom/nodejs_duration_small.csv";	 
	open(FH, $infile) or die "Cannot open $infile\n";
	my $tempUser=0;
	my $partConcat="";
	my $partConcatOld="";
	
	my @printArray;
	while ( my $line = <FH> )
	{
		chomp($line);
		my @values = split(',', $line);
		my $userId="";
		if ($tempUser != $values[0])     # when new user arrives
		{
			print ("IF  ");
			my $printLine= "$partConcatOld -2 \n";
			#print ("$printLine");
			push @printArray,$printLine;
			print ("$printLine\n");

			$partConcat="";
			$userId=$values[0];
			my $partId=$values[2];
			#print ("$userId>>>>>$partId\n");
		$tempUser=$userId;
		$partConcat=$partConcat.$userId."|".$partId.",".$values[6];
		}
		else                             # when we still have existing user
		{
			print ("ELSE   ");
			my $partId=$values[2];
			#print ("$partId\n");
			$partConcatOld=$partConcat."|".$partId;
			$partConcat=$partConcat."|".$partId.",".$values[6]."|";
			
		}
#			print "$partConcat __________________\n";


#		my $printString="$userId";
	
	}
	close(FH);	

		open (OUT, "> E:/Dropbox/OpenClassRoom/nodejs_duration_arranged.txt") or die "problem opening  nodejs_duration_arranged.txt\n";
		foreach (@printArray) {
			print OUT $_;
			print("$_\n");
		}
		close(OUT);

}





#Reading seceeion paths
# Same as "preprocessing()" but here we take do tieh part ID instead of part index
# Takes input the file nodejs2.csv having 2 columns
# USerid-PartIndex  Arranged according to UserIS and then the parts are arranged according to time.

##preprocessing1ReadScessPath_WithUserID();


#convert file for SPMF input -> Format: (2 3 4 5) -2
sub preprocessing1ReadScessPath_WithUserID{
my $infile = "E:/Dropbox/OpenClassRoom/nodejsReadScess.csv";

	my @seq;
	open(FH, $infile) or die "Cannot open $infile\n";
	my $tempUser=10;
	my $partConcat="";
	my @printArray;
	
	my $readSec;
	my $readSecPrev=10;
	my $partIdPrev=0;
	my @partReadSecChange;
	my @partReadSecChangeFreq;
	my @partReadSecChangeFreqTemp;

	while ( my $line = <FH> )
	{
#		 $tempUser=10;
		chomp($line);
		push @seq,$line;
		my @values = split(',', $line);
#		print ("$line, $values[0],$values[1]\n");
		my $userId="";
#		print ("____________________$tempUser\n");

		$readSec=$values[2];
		if ($tempUser != $values[0])
		{
			$partIdPrev=0;
#>			my $printLine= "$partConcat R$readSec \n";
			my $printLine= "$partConcat \n";
			print ("$printLine");
			push @printArray,$printLine;

			$partConcat="";
			$userId=$values[0];
			my $partId=$values[1];
			#print ("$userId>>>>>$partId\n");
		$tempUser=$userId;
#>		$partConcat=$partConcat.$partId." R".$readSec;
		$partConcat=$tempUser.",".$partConcat.$partId;

			if ($readSec!= $readSecPrev)
			{
				# print("RS change____________________________$tempUser,$partId\n");
				# $readSecPrev=$readSec;
			}

		}
		else
		{
			my $partId=$values[1];
			#print ("$partId\n");

			
			if ($readSec!= $readSecPrev)
			{
				if ($partIdPrev>0)
				{
				print("RS change____________________________$tempUser,$partIdPrev,$partId\n");

					push @partReadSecChange,"$tempUser,$partIdPrev,$partId\n";
					push @partReadSecChangeFreqTemp,"$partIdPrev,$partId";					

#>				$partConcat=$partConcat."  ".$partId."  RC".$readSec;
				$partConcat=$partConcat." ".$partId." R";

				}
				else
				{
#>					$partConcat=$partConcat."  ".$partId."  R".$readSec;
					$partConcat=$partConcat." ".$partId;
				}


				$readSecPrev=$readSec;
			}
			else
			{
#>				$partConcat=$partConcat."  ".$partId."  R".$readSec;			
				$partConcat=$partConcat." ".$partId;			
			}
			$partIdPrev=$partId;
			
			
		}
#			print "$partConcat __________________\n";


#		my $printString="$userId";
	
	}
	close(FH);	

		open (OUT, "> E:/Dropbox/OpenClassRoom/nodejsReadScesPathsWithUserID.txt") or die "problem opening  ./db/LamebrkPairsID.txt\n";
		foreach (@printArray) {
			print OUT $_;
		}
		close(OUT);

}






#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Same as "preprocessing()" but here we take do tieh part ID instead of part index   HERE WE TAKE INTO ACCOUNT THE READING SCESSION CHANGE
# Takes input the file nodejs2.csv having 2 columns
# USerid-PartIndex  Arranged according to UserIS and then the parts are arranged according to time.

#preprocesReadingScesChng();

sub preprocesReadingScesChng{
#my $infile = "E:/Dropbox/OpenClassRoom/abc.txt";
my $infile = "E:/Dropbox/OpenClassRoom/nodejsReadScess.csv";
	my @seq;
	open(FH, $infile) or die "Cannot open $infile\n";
	my $tempUser=10;
	my $readSec;
	my $readSecPrev=10;
	my $partIdPrev=0;
	my @partReadSecChange;
	my @partReadSecChangeFreq;
	my @partReadSecChangeFreqTemp;

	while ( my $line = <FH> )
	{
#		 $tempUser=10;
		chomp($line);
		push @seq,$line;
		my @values = split(',', $line);
		#print ("$line, $values[0],$values[1],$values[2]\n");
		my $userId="";
#		print ("____________________$tempUser\n");
		
		$readSec=$values[2];
		
		if ($tempUser != $values[0])   #if new user occurs
		{	$partIdPrev=0;
			#print("IF *************\n");

			$userId=$values[0];
			my $partId=$values[1];
			#print ("$userId>>>>>$partId\n");
		$tempUser=$userId;
			if ($readSec!= $readSecPrev)
			{
				# print("RS change____________________________$tempUser,$partId\n");
				# $readSecPrev=$readSec;
			}
		}
		else
		{
			#print("ELSE *************\n");
			
			my $partId=$values[1];
			
			#print ("$partId\n");
			if ($readSec!= $readSecPrev)
			{
				if ($partIdPrev>0)
				{
				print("RS change____________________________$tempUser,$partIdPrev,$partId\n");

					push @partReadSecChange,"$tempUser,$partIdPrev,$partId\n";
					push @partReadSecChangeFreqTemp,"$partIdPrev,$partId";
					
				}
				$readSecPrev=$readSec;
			}
			$partIdPrev=$partId;
			
		}
	
	}
	close(FH);	
#$$$$$$$$$$$$$$
	my  @array = @partReadSecChangeFreqTemp;
	my ($temp, $count) = ("@array", 0);
#	($count = $temp =~ s/($_)//g) and printf "%2d,%s\n", $count, $_ and push @partReadSecChangeFreq, "$_,$count\n" for @array;	
	($count = $temp =~ s/($_)//g) and push @partReadSecChangeFreq, "$_,$count\n" for @array;	

	writeArrayToFile("E:/Dropbox/OpenClassRoom/nodejsReadScessOutputFreq.txt",@partReadSecChangeFreq);
#$$$$$$$$$$$$$$

		open (OUT, "> E:/Dropbox/OpenClassRoom/nodejsReadScessOutputWithUser.txt") or die "problem opening  ./db/LamebrkPairsID.txt\n";
		foreach (@partReadSecChange) {
			print OUT $_;
		}
		close(OUT);

}




#Thaks input the file nodejs2.csv having 2 columns
#USerid-PartIndex  Arranged according to UserIS and then the parts are arranged according to time.

#preprocessing();
#Making of files needed for SPMF
sub preprocessing{
#my $infile = "E:/Dropbox/OpenClassRoom/abc.txt";
my $infile = "E:/Dropbox/OpenClassRoom/nodejs2.csv";	 
	my @seq;
	open(FH, $infile) or die "Cannot open $infile\n";
	my $tempUser=10;
	my $partConcat="";
	my @printArray;
	while ( my $line = <FH> )
	{
#		 $tempUser=10;
		chomp($line);
		push @seq,$line;
		my @values = split(',', $line);
#		print ("$line, $values[0],$values[1]\n");
		my $userId="";
#		print ("____________________$tempUser\n");
		if ($tempUser != $values[0])
		{
			my $printLine= "$partConcat -2 \n";
			print ("$printLine");
			push @printArray,$printLine;

			$partConcat="";
			$userId=$values[0];
			my $partId=$values[1];
			#print ("$userId>>>>>$partId\n");
		$tempUser=$userId;
		$partConcat=$partConcat.$userId." -1 ".$partId;
		}
		else
		{
			my $partId=$values[1];
			#print ("$partId\n");
			$partConcat=$partConcat." -1 ".$partId." -1 ";
			
		}
#			print "$partConcat __________________\n";


#		my $printString="$userId";
	
	}
	close(FH);	

	        #open (OUT, "> E:/Dropbox/OpenClassRoom/abcIN.txt") or die "problem opening  ./db/LamebrkPairsID.txt\n";
		open (OUT, "> E:/Dropbox/OpenClassRoom/nodejaINwithUserID.txt") or die "problem opening  ./db/LamebrkPairsID.txt\n";
		foreach (@printArray) {
			print OUT $_;
		}
		close(OUT);

}


# Same as "preprocessing()" but here we take do tieh part ID instead of part index
# Takes input the file nodejs2.csv having 2 columns
# USerid-PartIndex  Arranged according to UserIS and then the parts are arranged according to time.
#preprocessing1();
#convert file for SPMF input -> Format: (2 3 4 5) -2
sub preprocessing1{
#my $infile = "E:/Dropbox/OpenClassRoom/abc.txt";
my $infile = "E:/Dropbox/OpenClassRoom/nodejs21.csv";


	 
	my @seq;
	open(FH, $infile) or die "Cannot open $infile\n";
	my $tempUser=10;
	my $partConcat="";
	my @printArray;
	while ( my $line = <FH> )
	{
#		 $tempUser=10;
		chomp($line);
		push @seq,$line;
		my @values = split(',', $line);
#		print ("$line, $values[0],$values[1]\n");
		my $userId="";
#		print ("____________________$tempUser\n");
		if ($tempUser != $values[0])
		{
			my $printLine= "$partConcat -2 \n";
			print ("$printLine");
			push @printArray,$printLine;

			$partConcat="";
			$userId=$values[0];
			my $partId=$values[1];
			#print ("$userId>>>>>$partId\n");
		$tempUser=$userId;
		$partConcat=$partConcat.$partId;
		}
		else
		{
			my $partId=$values[1];
			#print ("$partId\n");
			$partConcat=$partConcat." -1 ".$partId." -1 ";
			
		}
#			print "$partConcat __________________\n";


#		my $printString="$userId";
	
	}
	close(FH);	

		open (OUT, "> E:/Dropbox/OpenClassRoom/nodejaIN1.txt") or die "problem opening  ./db/LamebrkPairsID.txt\n";
		foreach (@printArray) {
			print OUT $_;
		}
		close(OUT);

}

#postprocessing1();
sub postprocessing1{
#	my @lhs=(1111111,4444444);
	my @lhs=(1056764,1056764,1056866,1056793,1056866,1056793,1056865,1057142);
#	my @rhs=(2222222,3333333);
	my @rhs=(1056793,1056865,1056764,1056865,1056793,1056956,1056956,1056980);

#	my $infile = "E:/Dropbox/OpenClassRoom/abcIN.txt";
	my $infile = "E:/Dropbox/OpenClassRoom/nodejaINwithUserID.txt";

		open(FH, $infile) or die "Cannot open $infile\n";
		my @printArray;
		while ( my $line = <FH> )
		{
			chomp($line);
			my @values = split(' ', $line);
			my $userId="";

			for (my $iTh=0; $iTh <=$#lhs; $iTh++)
			{
					if(index($line,$lhs[$iTh])!=-1 and index($line,$rhs[$iTh])!=-1)
					{
						push @printArray,"$line\n";
						print ("$values[0] ___Found_____________\n");				
					}
			}	
		}
	
	close(FH);	

	my @unique = do { my %seen; grep { !$seen{$_}++ } @printArray };
	for (my $iTh=0; $iTh <=$#unique; $iTh++)
	{
		print "$unique[$iTh] \n\n\n";
	}


	open (OUT, "> E:/Dropbox/OpenClassRoom/uniqueResults.txt") or die "problem opening  ./db/LamebrkPairsID.txt\n";
		foreach (@unique) {
			print OUT $_;
		}
		close(OUT);



}





sub postprocessing{
#	my @lhs=(1111111,4444444);
	my @lhs=(1056764,1056764,1056866,1056793,1056866,1056793,1056865,1057142);
#	my @rhs=(2222222,3333333);
	my @rhs=(1056793,1056865,1056764,1056865,1056793,1056956,1056956,1056980);

#	my $infile = "E:/Dropbox/OpenClassRoom/abcIN.txt";
	my $infile = "E:/Dropbox/OpenClassRoom/nodejaINwithUserID.txt";

		open(FH, $infile) or die "Cannot open $infile\n";
		my @printArray;
		while ( my $line = <FH> )
		{
			chomp($line);
			my @values = split(' ', $line);
			my $userId="";

			for (my $iTh=0; $iTh <=$#lhs; $iTh++)
			{
					if(index($line,$lhs[$iTh])!=-1 and index($line,$rhs[$iTh])!=-1)
					{
						push @printArray,"$line\n";
						print ("$values[0] ___Found_____________\n");				
					}
			}	
		}
	
	close(FH);	

	my @unique = do { my %seen; grep { !$seen{$_}++ } @printArray };
	for (my $iTh=0; $iTh <=$#unique; $iTh++)
	{
		print "$unique[$iTh] \n\n\n";
	}


	open (OUT, "> E:/Dropbox/OpenClassRoom/uniqueResults.txt") or die "problem opening  ./db/LamebrkPairsID.txt\n";
		foreach (@unique) {
			print OUT $_;
		}
		close(OUT);

}


#Reads file line by line and puts in an array.   >>>>This is now in Util
sub readFileLinebyLineInArray()
{	
	my $infile = shift;
	my @seq;
	open(FH, $infile) or die "Cannot open $infile\n";
	while ( my $line = <FH> )
	{
		chomp($line);
		push @seq,$line;
	}
	close(FH);	
	return @seq;
}


	 	
	
	
	
