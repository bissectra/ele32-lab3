module LDPC

transmission_rate(dv, dc) = dc / (dc + dv)

# Gere um programa que seja capaz de projetar a matriz de verificação de
# paridade para um código LDPC regular para valores arbitrários de dv, dc e N
function design(dv, dc, N)

end

# Utilize o programa do item acima para projetar matrizes de verificação de
# paridade com taxa idêntica ao código de Hamming mas com comprimentos
# de aproximadamente 100, 200, 500 e 1000 bits. Use o valor de N correto
# mais próximo destes valores

function hamming_like(N)

end

# Implemente um decodificador que, com base na matriz de verificação de
# paridade, seja capaz de realizar o processo iterativo conforme o algoritmo
# bit-flipping
function decode(H, y, max_iter)

end

# Estime a probabilidade de erro de bit de informação para os 3 sistemas
# encontrados considerando que a palavra código é transmitida através de um
# canal BSC com parâmetro p = 0.1, 0.05, 0.002, 0.001, ....0.00001. Dica: a
# probabilidade de erro de bit é uniforme para todos os bits da palavra código.
function bit_error_probability(H, p, max_iter)

end
end

# Pontos a serem investigados
# ◼ Qual é a relação entre desempenho e probabilidade de
# erro de bit de informação?
# ◼ Compare o desempenho do sistema LDPC com os
# sistemas dos outros laboratórios.
# ◼ Qual é a complexidade de decodificação? Ela depende
# do valor de p?
# ◼ Quais foram as dificuldades de se projetar o código
# LDPC?