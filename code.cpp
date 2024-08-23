#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <vector>
#include <time.h>

using namespace std;

int KnuthYao(int Pmat[][16], int r, int q, int MAXROW, int MAXCOL) {
    int d = 0;
    for (int col = 0; col < MAXCOL; col++) {
        d = 2 * d + (r & 1);
        r = r >> 1;
        for (int row = MAXROW - 1; row >= 0; row--) {
            d = d - Pmat[row][col];
            if (d == -1) {
                if ((r & 1) == 1)
                    return q - row;
                else
                    return row;
            }
        }
    }
    return 0;
}

vector < int > generatePoly() {
    int P[7681][16];
/*********************** 
This array P stores a probability distribution to be used in Knuth Yao sampler. It is NOT
initialized here because the initialization takes 7600 lines of code.
******************************************/
    int q = 7681;
    int arr[256];
    for (int i = 0; i < 256; i++) {
        int r = rand() % 7681;
        int res = KnuthYao(P, r, q, 7681, 16);
        arr[i] = res;
    }
    vector < int > ans(begin(arr), end(arr));
    return ans;
}

int inverse(int n) {
    for (int i = 0; i < 7681; i++) {
        if ((i * n) % 7681 == 1)
            return i;
    }
    return 1;
}

vector < int > recfft(vector < int > a) {
    int N = a.size();
    int omegN, omega = 1;
    if (N == 1)
        return a;
    else if (N == 256)
        omegN = 198;
    else if (N == 128)
        omegN = 799;
    else if (N == 64)
        omegN = 878;
    else if (N == 32)
        omegN = 2784;
    else if (N == 16)
        omegN = 527;
    else if (N == 8)
        omegN = 1213;
    else if (N == 4)
        omegN = 4298;
    else if (N == 2)
        omegN = 7680;
    vector < int > a0;
    for (int i = 0; i < N / 2; i++)
        a0.push_back(a[2 * i]);
    vector < int > a1;
    for (int i = 0; i < N / 2; i++)
        a1.push_back(a[2 * i + 1]);
    vector < int > y0 = recfft(a0);
    vector < int > y1 = recfft(a1);
    vector < int > y(N, 0);
    for (int k = 0; k < N / 2; k++) {
        y[k] = y0[k] + (omega * y1[k]) % 7681;
        y[k + N / 2] = y0[k] - (omega * y1[k]) % 7681;
        omega = (omega * omegN) % 7681;
    }
    if (y.size() == 256) {
        for (int i = 0; i < y.size(); i++) {
            y[i] %= 7681;
            y[i] += 7681;
            y[i] %= 7681;
        }
    }
    return y;
}

vector < int > recinfft(vector < int > a) {
    int N = a.size();
    int omegN, omega = 1;
    if (N == 1)
        return a;
    else if (N == 256)
        omegN = 1125;
    else if (N == 128)
        omegN = 5941;
    else if (N == 64)
        omegN = 1286;
    else if (N == 32)
        omegN = 2381;
    else if (N == 16)
        omegN = 583;
    else if (N == 8)
        omegN = 1925;
    else if (N == 4)
        omegN = 3383;
    else if (N == 2)
        omegN = 7680;
    vector < int > a0;
    for (int i = 0; i < N / 2; i++)
        a0.push_back(a[2 * i]);
    vector < int > a1;
    for (int i = 0; i < N / 2; i++)
        a1.push_back(a[2 * i + 1]);
    vector < int > y0 = recinfft(a0);
    vector < int > y1 = recinfft(a1);
    vector < int > y(N, 0);
    for (int k = 0; k < N / 2; k++) {
        y[k] = y0[k] + (omega * y1[k]) % 7681;
        y[k + N / 2] = y0[k] - (omega * y1[k]) % 7681;
        omega = (omega * omegN) % 7681;
    }
    if (y.size() == 256) {
        for (int i = 0; i < y.size(); i++) {
            y[i] %= 7681;
            y[i] += 7681;
            y[i] %= 7681;
            y[i] *= inverse(y.size());
            y[i] %= 7681;
        }
    }
    return y;
}

vector < vector < int > > KeyGen(vector < int > acap) {
    vector < int > r1 = generatePoly();
    vector < int > r2 = generatePoly();
    cout << endl;
    vector < int > r1cap = recfft(r1);
    vector < int > r2cap = recfft(r2);
    cout << endl;
    vector < int > pcap;
    for (int i = 0; i < 256; i++) {
        int ans = r1cap[i] - acap[i] * r2cap[i];
        ans %= 7681;
        ans += 7681;
        ans %= 7681;
        pcap.push_back(ans);
    }
    vector < vector < int > > result;
    result.push_back(acap);
    result.push_back(pcap);
    result.push_back(r2cap);
    return result;
}

vector < vector < int > > Encryption(vector < int > acap, vector < int >
    pcap, vector < int > M) {
    for (int i = 0; i < M.size(); i++)
        M[i] *= 3840;
    vector < int > e1 = generatePoly();
    vector < int > e2 = generatePoly();
    vector < int > e3 = generatePoly();
    vector < int > C1cap;
    vector < int > C2cap;
    for (int i = 0; i < M.size(); i++)
        M[i] = (M[i] + e3[i]) % 7681;
    vector < int > Mt = recfft(M);
    vector < int > e1cap = recfft(e1);
    vector < int > e2cap = recfft(e2);
    for (int i = 0; i < M.size(); i++) {
        C1cap[i] = (acap[i] * e1cap[i] + e2cap[i]) % 7681;
        C2cap[i] = (pcap[i] * e1cap[i] + Mt[i]) % 7681;
    }
    vector < vector < int > > result;
    result.push_back(C1cap);
    result.push_back(C2cap);
    return result;
}

vector < int > Decryption(vector < int > C1cap, vector < int > C2cap,
    vector < int > r2cap) {
    vector < int > dec;
    for (int i = 0; i < C1cap.size(); i++)
        dec[i] = (r2cap[i] * C1cap[i] + C2cap[i]) % 7681;
    vector < int > result = recinfft(dec);
    return result;
}