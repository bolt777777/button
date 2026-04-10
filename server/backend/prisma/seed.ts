import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  const hash = (pw: string) => bcrypt.hashSync(pw, 10);

  // Organization
  const org = await prisma.organization.upsert({
    where: { id: '00000000-0000-0000-0000-000000000001' },
    update: {},
    create: {
      id: '00000000-0000-0000-0000-000000000001',
      name: 'Demo Security Co.',
    },
  });

  // SuperAdmin
  await prisma.adminAccount.upsert({
    where: { email: 'super@bodyguard.dev' },
    update: {},
    create: {
      email: 'super@bodyguard.dev',
      passwordHash: hash('super123'),
      role: 'superadmin',
      orgId: org.id,
    },
  });

  // Admin
  await prisma.adminAccount.upsert({
    where: { email: 'admin@bodyguard.dev' },
    update: {},
    create: {
      email: 'admin@bodyguard.dev',
      passwordHash: hash('admin123'),
      role: 'admin',
      orgId: org.id,
    },
  });

  // Operator
  await prisma.adminAccount.upsert({
    where: { email: 'operator@bodyguard.dev' },
    update: {},
    create: {
      email: 'operator@bodyguard.dev',
      passwordHash: hash('operator123'),
      role: 'operator',
      orgId: org.id,
    },
  });

  // Test user (mobile app client)
  await prisma.user.upsert({
    where: { email: 'user@bodyguard.dev' },
    update: {},
    create: {
      name: 'Тестовый Клиент',
      email: 'user@bodyguard.dev',
      passwordHash: hash('user123'),
      phone: '+79001234567',
      orgId: org.id,
    },
  });

  // Test guards
  const guardData = [
    {
      name: 'Иванов Алексей',
      email: 'guard1@bodyguard.dev',
      lat: 55.753,
      lng: 37.621,
    },
    {
      name: 'Петров Сергей',
      email: 'guard2@bodyguard.dev',
      lat: 55.749,
      lng: 37.615,
    },
    {
      name: 'Сидорова Мария',
      email: 'guard3@bodyguard.dev',
      lat: 55.756,
      lng: 37.625,
    },
  ];

  for (const g of guardData) {
    await prisma.guard.upsert({
      where: { email: g.email },
      update: {},
      create: {
        name: g.name,
        email: g.email,
        passwordHash: hash('guard123'),
        phone: '+7900000000' + guardData.indexOf(g),
        status: 'available',
        currentLat: g.lat,
        currentLng: g.lng,
        orgId: org.id,
      },
    });
  }

  console.log('Seed complete.');
  console.log('Accounts:');
  console.log('  super@bodyguard.dev / super123 (superadmin)');
  console.log('  admin@bodyguard.dev / admin123 (admin)');
  console.log('  operator@bodyguard.dev / operator123 (operator)');
  console.log('  user@bodyguard.dev / user123 (mobile user)');
  console.log('  guard1..3@bodyguard.dev / guard123 (guards)');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
