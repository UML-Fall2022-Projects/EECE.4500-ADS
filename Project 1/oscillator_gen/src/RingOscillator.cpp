#include "RingOscillator.h"

#include <algorithm>
#include <random>
#include <sstream>

RingOscillator::RingOscillator(int id)
    : m_id{id}, m_gen{m_rd()}
{
    GenerateParams();
}

void RingOscillator::GenerateParams() {
    const float min_lw{0.85f};
    const float max_lw{1.15f};
    const float min_toxe{0.9f};
    const float max_toxe{1.1f};

    for(int i = 0; i < 13; i++) {
        m_pmosParams.tplv[i] = std::clamp<float>(m_rand_lw(m_gen), min_lw, max_lw);
        m_pmosParams.tpwv[i] = std::clamp<float>(m_rand_lw(m_gen), min_lw, max_lw);
        m_pmosParams.tpotv[i] = std::clamp<float>(m_rand_toxe(m_gen), min_toxe, max_toxe);

        m_nmosParams.tnlv[i] = std::clamp<float>(m_rand_lw(m_gen), min_lw, max_lw);
        m_nmosParams.tnwv[i] = std::clamp<float>(m_rand_lw(m_gen), min_lw, max_lw);
        m_nmosParams.tnotv[i] = std::clamp<float>(m_rand_toxe(m_gen), min_toxe, max_toxe);
    }
}

std::ostream& operator<<(std::ostream& os, const RingOscillator& ro) {
    std::stringstream title_ss;
    title_ss << "ring_oscillator_" << ro.m_id;
    std::string name = title_ss.str();

    os << "*" << name << "\n.include nand.cir\n.include inverter.cir\n\n";
    os << ".subckt " << name << "enable output vdd vss\n";

    os << "X1 enable out c0 vdd vss nand tplv=" << ro.m_pmosParams.tplv[0] << " tpwv=" << ro.m_pmosParams.tpwv[0];
    os << " tnlv=" << ro.m_nmosParams.tnlv[0] << " tnwv=" << ro.m_nmosParams.tnwv[0];
    os << " tpotv=" << ro.m_pmosParams.tpotv[0] << " tnotv=" << ro.m_nmosParams.tnotv[0] << '\n';

    for(int i = 1; i < 12; i++) {
        os << "X" << i + 1 << " c" << i - 1 << " c" << i << " vdd vss inverter tplv=" << ro.m_pmosParams.tplv[i] << " tpwv=" << ro.m_pmosParams.tpwv[i];
        os << " tnlv=" << ro.m_nmosParams.tnlv[i] << " tnwv=" << ro.m_nmosParams.tnwv[i];
        os << " tpotv=" << ro.m_pmosParams.tpotv[i] << " tnotv=" << ro.m_nmosParams.tnotv[i] << '\n';
    }
    os << "X13 c11 out vdd vss inverter tplv=" << ro.m_pmosParams.tplv[12] << " tpwv=" << ro.m_pmosParams.tpwv[12];
    os << " tnlv=" << ro.m_nmosParams.tnlv[12] << " tnwv=" << ro.m_nmosParams.tnwv[12];
    os << " tpotv=" << ro.m_pmosParams.tpotv[12] << " tnotv=" << ro.m_nmosParams.tnotv[12] << '\n';

    os << "\n\n.ends ring_oscillator";

    return os;
}
