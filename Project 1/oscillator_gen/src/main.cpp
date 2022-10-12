#include <iostream>
#include <fstream>
#include <sstream>

#include "RingOscillator.h"

int main() {
    for(int i = 0; i < 8; i++) {
        std::stringstream filename;
        filename << "ring_oscillator_" << i << ".cir";

        std::ofstream file;
        file.open(filename.str());

        RingOscillator ro{i};
        file << ro;

        file.close();
    }

    return 0;
}
