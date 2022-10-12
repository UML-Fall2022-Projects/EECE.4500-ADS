#pragma once

#include <iostream>
#include <random>

class RingOscillator {
public:
    RingOscillator(int id);

    friend std::ostream& operator<<(std::ostream& os, const RingOscillator& ro);
private:
    void GenerateParams();
private:
    int m_id;

    std::random_device m_rd;
    std::mt19937 m_gen;
    std::normal_distribution<float> m_rand_lw{1.0f, 0.065f};
    std::normal_distribution<float> m_rand_toxe{1.0f, 0.05f};

    struct PMOSParams {
        float tplv[13];
        float tpwv[13];
        float tpotv[13];
    } m_pmosParams;

    struct NMOSParams {
        float tnlv[13];
        float tnwv[13];
        float tnotv[13];
    } m_nmosParams;
};

std::ostream& operator<<(std::ostream& os, const RingOscillator& ro);
