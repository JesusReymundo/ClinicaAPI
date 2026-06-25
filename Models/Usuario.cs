using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ClinicaAPI.Models;

[Table("Usuario")]
public class Usuario
{
    [Key]
    public int IdUsuario { get; set; }
    public int IdRol { get; set; }
    [Required, MaxLength(100)]
    public string Nombres { get; set; } = string.Empty;
    [Required, MaxLength(100)]
    public string Apellidos { get; set; } = string.Empty;
    [Required, MaxLength(10)]
    public string TipoDocumento { get; set; } = "DNI";   // DNI / CE / RUC / PASAPORTE
    [Required, MaxLength(20)]
    public string NumeroDocumento { get; set; } = string.Empty;
    public DateTime? FechaNacimiento { get; set; }
    [MaxLength(1)]
    public string? Genero { get; set; }
    [MaxLength(200)]
    public string? Direccion { get; set; }
    [Required, MaxLength(50)]
    public string Username { get; set; } = string.Empty;
    [Required, MaxLength(256)]
    public string PasswordHash { get; set; } = string.Empty;
    public bool Activo { get; set; } = true;
    public DateTime FechaCreacion { get; set; } = DateTime.Now;
    public DateTime? FechaModificacion { get; set; }
    public int? IdUsuarioCreacion { get; set; }
    public int? IdUsuarioModificacion { get; set; }

    [ForeignKey("IdRol")]
    public Rol? Rol { get; set; }
    public ICollection<Contacto> Contactos { get; set; } = new List<Contacto>();
}
