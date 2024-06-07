#!/usr/bin/perl


#warnings é chamado de pragma. Instrucao para relatorios adicionais


use warnings;
our $color = 'red'; #our decxlaracao global de variavel
print("my favorite #1 color is " . $color . "\n");

# outro bloco

{
    my $color = 'blue';
    print("my favorite #2 color is " . $color . "\n");
}

print("my favorite #1 color is " .$color. "\n");