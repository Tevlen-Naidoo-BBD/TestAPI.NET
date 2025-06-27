using Microsoft.EntityFrameworkCore;
using PetStoreAPI.Models;
using PetStoreAPI.Dtos;

namespace PetStoreAPI.Data
{
    public class PetStoreContext : DbContext
    {
        public PetStoreContext(DbContextOptions<PetStoreContext> options) : base(options) { }

        public DbSet<Pet> Pets { get; set; }
        public DbSet<User> Users { get; set; }
        public DbSet<Order> Orders { get; set; }
        public DbSet<PetDetailsDto> PetDetails { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            modelBuilder.Entity<PetDetailsDto>().HasNoKey();
        }
    }
} 