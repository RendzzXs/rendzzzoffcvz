#!/bin/bash
# ============================================
#   🎨 RENDZZ INNER PANEL v4.0
#   Custom Admin UI • User Expired • Icons
# ============================================

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; MAGENTA='\033[0;35m'; NC='\033[0m'

[[ $EUID -ne 0 ]] && { echo -e "${RED}❌ Harus root!${NC}"; exit 1; }

clear
echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║  🎨 RENDZZ INNER PANEL v4.0                ║${NC}"
echo -e "${CYAN}║  Admin UI • Expired User • Full Icons      ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
echo ""

PTERO_DIR="/var/www/pterodactyl"
TARGET_FILE="$PTERO_DIR/resources/views/templates/base/core.blade.php"

if [ ! -d "$PTERO_DIR" ]; then
    echo -e "${RED}❌ Folder Pterodactyl tidak ditemukan!${NC}"
    exit 1
fi

# ============ 1. TAMBAH FITUR EXPIRED DI DATABASE ============
echo -e "${CYAN}[1/3] Update Database (Kolom Expired User)...${NC}"
DB_NAME="panel" # Default nama db pterodactyl
DB_USER="pterodactyl"
DB_PASS=$(grep "DB_PASSWORD" "$PTERO_DIR/.env" | cut -d '=' -f2 | tr -d '"')

# Cek apakah pakai password kosong atau tidak
if [ -z "$DB_PASS" ]; then
    DB_PASS=$(grep "DB_PASSWORD" "$PTERO_DIR/.env" | cut -d '=' -f2)
fi

# Eksekusi query (Tambah kolom expired_at jika belum ada)
mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "SHOW COLUMNS FROM users LIKE 'expired_at';" 2>/dev/null | grep -q expired_at || \
    mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "ALTER TABLE users ADD COLUMN expired_at DATETIME DEFAULT NULL;"

echo -e "${GREEN}  ✓ Kolom 'expired_at' siap di database${NC}"

# ============ 2. INJECT CSS CUSTOM (UI BARU) ============
echo -e "${CYAN}[2/3] Inject Custom CSS & Icon...${NC}"

# Backup dulu
cp "$TARGET_FILE" "$TARGET_FILE.bak"

# Bikin file CSS eksternal biar gak numpuk di blade
CSS_DIR="$PTERO_DIR/public/rendzz"
mkdir -p "$CSS_DIR"

cat > "$CSS_DIR/custom-admin.css" << 'CSSEOF'
/* ========================================== */
/* RENDZZ PREMIUM ADMIN UI                    */
/* ========================================== */

@import url('https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css');

:root {
    --rd-bg: #0f172a;
    --rd-card: #1e293b;
    --rd-primary: #38bdf8;
    --rd-text: #e2e8f0;
    --rd-muted: #64748b;
}

/* --- SIDEBAR ELEGAN --- */
.sidebar {
    background: var(--rd-bg) !important;
    border-right: 1px solid rgba(255,255,255,0.05) !important;
    box-shadow: 4px 0 24px rgba(0,0,0,0.5) !important;
}

.sidebar .nav-link {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 12px 20px !important;
    margin: 4px 12px !important;
    border-radius: 12px !important;
    color: var(--rd-muted) !important;
    font-weight: 600;
    transition: all 0.3s ease;
}

.sidebar .nav-link:hover, 
.sidebar .nav-link.active {
    background: rgba(56, 189, 248, 0.1) !important;
    color: var(--rd-primary) !important;
    transform: translateX(5px);
}

/* Icon rapi (FontAwesome) */
.sidebar .nav-link .icon {
    font-size: 1.2rem;
    width: 24px;
    text-align: center;
    filter: drop-shadow(0 0 5px rgba(56,189,248,0.5));
}

/* --- TOP HEADER --- */
.content-wrapper .main-header {
    background: rgba(15, 23, 42, 0.9) !important;
    backdrop-filter: blur(10px);
    border-bottom: 1px solid rgba(255,255,255,0.05) !important;
    box-shadow: 0 4px 20px rgba(0,0,0,0.3) !important;
}

/* --- SERVER CARD (Hexagon) --- */
.server-card {
    background: var(--rd-card) !important;
    border-radius: 20px 8px 20px 8px !important;
    border: 1px solid rgba(255,255,255,0.05) !important;
    box-shadow: 0 10px 30px rgba(0,0,0,0.2) !important;
    transition: transform 0.3s ease, box-shadow 0.3s ease;
    position: relative;
    overflow: hidden;
}

.server-card::before {
    content: '';
    position: absolute;
    top: 0; left: 0; width: 5px; height: 100%;
    background: linear-gradient(180deg, #38bdf8, #818cf8);
}

.server-card:hover {
    transform: translateY(-8px) scale(1.02);
    box-shadow: 0 20px 40px rgba(56,189,248,0.15) !important;
}

/* --- BADGE EXPIRED / VIP --- */
.badge-expired {
    background: linear-gradient(135deg, #ef4444, #b91c1c);
    color: white;
    padding: 4px 10px;
    border-radius: 20px;
    font-size: 0.75rem;
    font-weight: 700;
    display: inline-flex;
    align-items: center;
    gap: 5px;
    box-shadow: 0 4px 10px rgba(239, 68, 68, 0.4);
}

.badge-vip {
    background: linear-gradient(135deg, #f59e0b, #b45309);
    color: white;
    padding: 4px 10px;
    border-radius: 20px;
    font-size: 0.75rem;
    font-weight: 700;
    display: inline-flex;
    align-items: center;
    gap: 5px;
    box-shadow: 0 4px 10px rgba(245, 158, 11, 0.4);
}

/* --- TABLE / LIST USER --- */
table tbody tr {
    transition: background 0.2s;
}
table tbody tr:hover {
    background: rgba(56, 189, 248, 0.05) !important;
}

/* --- SCROLLBAR --- */
::-webkit-scrollbar { width: 8px; }
::-webkit-scrollbar-track { background: var(--rd-bg); }
::-webkit-scrollbar-thumb { background: var(--rd-muted); border-radius: 10px; }
::-webkit-scrollbar-thumb:hover { background: var(--rd-primary); }
CSSEOF

# Sisipkan link CSS ke dalam file blade
if ! grep -q "custom-admin.css" "$TARGET_FILE"; then
    sed -i "s|</head>|<link rel=\"stylesheet\" href=\"/rendzz/custom-admin.css\">\n</head>|" "$TARGET_FILE" 2>/dev/null
    # Kalau gak ada </head> di core.blade, taruh di atas
    if ! grep -q "custom-admin.css" "$TARGET_FILE"; then
        sed -i "1s|^|@push('styles')\n<link rel=\"stylesheet\" href=\"/rendzz/custom-admin.css\">\n@endpush\n|" "$TARGET_FILE"
    fi
fi

echo -e "${GREEN}  ✓ CSS Custom & Icon di-inject${NC}"

# ============ 3. GANTI ICON SIDEBAR (Pake FontAwesome) ============
echo -e "${CYAN}[3/3] Ganti Icon Sidebar jadi FontAwesome...${NC}"

# Cari file sidebar (biasanya ada di resources/scripts/components/NavigationBar.tsx atau sidebar.blade.php)
# Kita pakai cara paling universal: Inject CSS biar ngeganti icon bawaan
cat >> "$CSS_DIR/custom-admin.css" << 'CSSEOF'

/* Ganti Icon SVG bawaan Pterodactyl jadi FontAwesome */
/* Dashboard */
.nav-link[href="/"] .icon svg { display: none; }
.nav-link[href="/"] .icon::before { content: "\f015"; font-family: "Font Awesome 6 Free"; font-weight: 900; }

/* Server / Console */
.nav-link[href*="/server/"] .icon svg { display: none; }
.nav-link[href*="/server/"] .icon::before { content: "\f120"; font-family: "Font Awesome 6 Free"; font-weight: 900; }

/* Account / Profile */
.nav-link[href*="/account"] .icon svg { display: none; }
.nav-link[href*="/account"] .icon::before { content: "\f007"; font-family: "Font Awesome 6 Free"; font-weight: 900; }

/* Admin Panel */
.nav-link[href*="/admin"] .icon svg { display: none; }
.nav-link[href*="/admin"] .icon::before { content: "\f505"; font-family: "Font Awesome 6 Free"; font-weight: 900; }
CSSEOF

# Clear cache
cd "$PTERO_DIR" 2>/dev/null
php artisan view:clear >/dev/null 2>&1
php artisan cache:clear >/dev/null 2>&1
php artisan config:clear >/dev/null 2>&1

chown -R www-data:www-data "$PTERO_DIR/public/rendzz" 2>/dev/null
chown -R www-data:www-data "$PTERO_DIR/resources/views" 2>/dev/null

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✅ INNER PANEL UPDATE SELESAI!            ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
echo -e "${CYAN}🚀 Silakan refresh panel Pterodactyl (CTRL+SHIFT+R)${NC}"
echo ""
